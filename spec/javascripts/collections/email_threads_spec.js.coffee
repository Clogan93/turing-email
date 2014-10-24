describe "EmailThreadsCollection", ->
  beforeEach ->
    @emailThreadsCollection = new TuringEmailApp.Collections.EmailThreadsCollection(undefined, app: TuringEmailApp)
    
  it "should use the EmailThread model", ->
    expect(@emailThreadsCollection.model).toEqual(TuringEmailApp.Models.EmailThread)

  describe "#initialize", ->
    beforeEach ->
      @emailThreadsCollectionTemp = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
        app: TuringEmailApp
        folderID: "INBOX"
      )

    it "initializes the variables", ->
      expect(@emailThreadsCollectionTemp.app).toEqual(TuringEmailApp)
      expect(@emailThreadsCollectionTemp.pageTokens).toEqual([null])
      expect(@emailThreadsCollectionTemp.pageTokenIndex).toEqual(0)
      expect(@emailThreadsCollectionTemp.folderID).toEqual("INBOX")
    
  describe "Network", ->
    describe "#sync", ->
      beforeEach ->
        @superStub = sinon.stub(TuringEmailApp.Collections.EmailThreadsCollection.__super__, "sync")
        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
        @triggerStub = sinon.stub(@emailThreadsCollection, "trigger", ->)

      afterEach ->
        @triggerStub.restore()
        @googleRequestStub.restore()
        @superStub.restore()

      describe "write", ->
        beforeEach ->
          @method = "write"
          @collection = {}
          @options = {}

          @emailThreadsCollection.sync(@method, @collection, @options)

        it "calls super", ->
          expect(@superStub).toHaveBeenCalledWith(@method, @collection, @options)

        it "does NOT call googleRequest", ->
          expect(@googleRequestStub).not.toHaveBeenCalled()

        it "does not trigger the request event", ->
          expect(@triggerStub).not.toHaveBeenCalled()

      describe "read", ->
        beforeEach ->
          @collection = {}
          @options = error: sinon.stub()
          @emailThreadsCollection.sync("read", @collection, @options)

        it "does not call super", ->
          expect(@superStub).not.toHaveBeenCalled()

        it "calls googleRequest", ->
          expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
          specCompareFunctions((=> @threadsListRequest(options)), @googleRequestStub.args[0][1])
          specCompareFunctions(((response) => @processThreadsListRequest(response, options)), @googleRequestStub.args[0][2])
          expect(@googleRequestStub.args[0][3]).toEqual(@options.error)

        it "triggers the request event", ->
          expect(@triggerStub).toHaveBeenCalledWith("request", @collection, null, @options)

    describe "#threadsListRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: threads: list: ->

        @ret = {}
        @threadsListStub = sinon.stub(gapi.client.gmail.users.threads, "list", => return @ret)

        @params =
          userId: "me"
          maxResults: TuringEmailApp.Models.UserSettings.EmailThreadsPerPage
          fields: "nextPageToken,threads(id)"

      afterEach ->
        @threadsListStub.restore()

      it "prepares and returns the Gmail API request", ->
        @returned = @emailThreadsCollection.threadsListRequest()
        
        expect(@threadsListStub).toHaveBeenCalledWith(@params)
        expect(@returned).toEqual(@ret)
      
      describe "with folderID", ->
        beforeEach ->
          @emailThreadsCollection.folderIDIs("test")
          @params["labelIds"] = @emailThreadsCollection.folderID
          
          @returned = @emailThreadsCollection.threadsListRequest()
        
        it "prepares and returns the Gmail API request", ->
          expect(@threadsListStub).toHaveBeenCalledWith(@params)
          expect(@returned).toEqual(@ret)

      describe "with pageToken", ->
        beforeEach ->
          @emailThreadsCollection.pageTokens[0] = "token"
          @params["pageToken"] = @emailThreadsCollection.pageTokens[0]
          
          @returned = @emailThreadsCollection.threadsListRequest()

        it "prepares and returns the Gmail API request", ->
          expect(@threadsListStub).toHaveBeenCalledWith(@params)
          expect(@returned).toEqual(@ret)

      describe "with query", ->
        beforeEach ->
          @params["q"] = "test"
          
          @returned = @emailThreadsCollection.threadsListRequest(query: "test")
          
        it "prepares and returns the Gmail API request", ->
          expect(@threadsListStub).toHaveBeenCalledWith(@params)
          expect(@returned).toEqual(@ret)
          
    describe "#processThreadsListRequest", ->
      beforeEach ->
        @response = fixture.load("gmail_api/users.threads.list.fixture.json")[0]
        @options = {success: sinon.stub()}
        @loadThreadsStub = sinon.stub(@emailThreadsCollection, "loadThreads", ->)
        
      afterEach ->
        @loadThreadsStub.restore()

      describe "with threads", ->
        beforeEach ->
          @emailThreadsCollection.processThreadsListRequest(@response, @options)

        it "updates the page tokens", ->
          expect(@emailThreadsCollection.pageTokens).toEqual([null, @response.result.nextPageToken])

        it "loads the threads", ->
          expect(@loadThreadsStub).toHaveBeenCalledWith(@response.result.threads, @options)
          
        it "does not call success", ->
          expect(@options.success).not.toHaveBeenCalled()

      describe "without threads", ->
        beforeEach ->
          @response.result.threads = undefined

          @emailThreadsCollection.processThreadsListRequest(@response, @options)
          
        it "updates the page tokens", ->
          expect(@emailThreadsCollection.pageTokens).toEqual([null, @response.result.nextPageToken])
          
        it "does not load the threads", ->
          expect(@loadThreadsStub).not.toHaveBeenCalled()
          
        it "calls success", ->
          expect(@options.success).toHaveBeenCalledWith([])

    describe "#loadThreads", ->
      beforeEach ->
        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
        threadsListResponse = fixture.load("gmail_api/users.threads.list.fixture.json")[0]
        threadsListInfo = threadsListResponse.result.threads

        @error = sinon.stub()
        @emailThreadsCollection.loadThreads(threadsListInfo, error: @error)

      afterEach ->
        @googleRequestStub.restore()

      it "calls googleRequest", ->
        expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
        specCompareFunctions((=> @threadsGetBatch(threadsListInfo)), @googleRequestStub.args[0][1])
        specCompareFunctions(((response) => @processThreadsGetBatch(response, options)), @googleRequestStub.args[0][2])
        expect(@googleRequestStub.args[0][3]).toEqual(@error)
          
  describe "#threadsGetBatch", ->
    beforeEach ->
      @batch = add: =>
      @addStub = sinon.stub(@batch, "add", =>)

      window.gapi =
        client:
          newBatch: => @batch

          gmail:
            users:
              threads: get: ->

      @threadsGetStub = sinon.stub(gapi.client.gmail.users.threads, "get", (params) => params)

      threadsListResponse = fixture.load("gmail_api/users.threads.list.fixture.json")[0]
      @threadsListInfo = threadsListResponse.result.threads
      @returned = @emailThreadsCollection.threadsGetBatch(@threadsListInfo)

    it "adds the items to the batch", ->
      for threadInfo in @threadsListInfo
        params =
          userId: "me",
          id: threadInfo.id
          fields: "id,historyId,messages(id,labelIds)"

        expect(@threadsGetStub).toHaveBeenCalledWith(params)
        expect(@addStub).toHaveBeenCalledWith(params)

    it "returns the batch", ->
      expect(@returned).toEqual(@batch)
    
  describe "#processThreadsGetBatch", ->
    beforeEach ->
      response = fixture.load("gmail_api/users.threads.get.batch.fixture.json")[0]
      threadsResults = _.values(response.result)
      @threadsInfo = _.pluck(threadsResults, "result")

      @loadThreadsPreviewStub = sinon.stub(@emailThreadsCollection, "loadThreadsPreview", ->)
      @options = {}
      @emailThreadsCollection.processThreadsGetBatch(response, @options)
      
    afterEach ->
      @loadThreadsPreviewStub.restore()
    
    it "loads the thread previews", ->
      expect(@loadThreadsPreviewStub).toHaveBeenCalledWith(@threadsInfo, @options)
      
  describe "#loadThreadsPreview", ->
    beforeEach ->
      @googleRequestStub = sinon.stub(window, "googleRequest", ->)
      response = fixture.load("gmail_api/users.threads.get.batch.fixture.json")[0]
      threadsResults = _.values(response.result)
      @threadsInfo = _.pluck(threadsResults, "result")
    
      @error = sinon.stub()
      @emailThreadsCollection.loadThreadsPreview(@threadsInfo, error: @error)
    
    afterEach ->
      @googleRequestStub.restore()
  
    it "calls googleRequest", ->
      expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
      specCompareFunctions((=> @messagesGetBatch(threadsInfo)), @googleRequestStub.args[0][1])
      specCompareFunctions(((response) => @processMessagesGetBatch(response, threadsInfo, options)),
                           @googleRequestStub.args[0][2])
      expect(@googleRequestStub.args[0][3]).toEqual(@error)
      
  describe "#messagesGetBatch", ->
    beforeEach ->
      @batch = add: =>
      @addStub = sinon.stub(@batch, "add", =>)

      window.gapi =
        client:
          newBatch: => @batch

          gmail:
            users:
              messages: get: ->

      @messagesGetStub = sinon.stub(gapi.client.gmail.users.messages, "get", (params) => params)

      response = fixture.load("gmail_api/users.threads.get.batch.fixture.json")[0]
      threadsResults = _.values(response.result)
      @threadsInfo = _.pluck(threadsResults, "result")
      @returned = @emailThreadsCollection.messagesGetBatch(@threadsInfo)

    it "adds the items to the batch", ->
      for threadInfo in @threadsInfo
        lastMessage =_.last(threadInfo.messages)
        
        params =
          userId: "me"
          id: lastMessage.id
          format: "metadata"
          metadataHeaders: ["date", "from", "subject"]
          fields: "payload,snippet"

        expect(@messagesGetStub).toHaveBeenCalledWith(params)
        expect(@addStub).toHaveBeenCalledWith(params)

    it "returns the batch", ->
      expect(@returned).toEqual(@batch)
      
  describe "#processMessagesGetBatch", ->
      beforeEach ->
        threadsGetBatchResponse = fixture.load("gmail_api/users.threads.get.batch.fixture.json")[0]
        threadsResults = _.values(threadsGetBatchResponse.result)
        @threadsInfo = _.pluck(threadsResults, "result")

        @response = fixture.load("gmail_api/users.messages.get.batch.fixture.json")[0]
        @options = success: sinon.stub()
        
        @threadsParsed = fixture.load("gmail_api/users.threads.parsed.fixture.json")[0]

        @threadFromMessageInfoSpy = sinon.spy(@emailThreadsCollection, "threadFromMessageInfo")
        
        @emailThreadsCollection.processMessagesGetBatch(@response, @threadsInfo, @options)
        
      afterEach ->
        @threadFromMessageInfoSpy.restore()

      it "calls threadFromMessageInfo on each thread", ->
        for threadInfo in @threadsInfo
          lastMessage =_.last(threadInfo.messages)
          lastMessageResponse = @response.result[lastMessage.id]

          expect(@threadFromMessageInfoSpy).toHaveBeenCalledWith(threadInfo, lastMessageResponse.result)

      it "calls success with the parsed threads", ->
        expect(@options.success).toHaveBeenCalled()
        expect(JSON.stringify(@options.success.args[0][0])).toEqual(JSON.stringify(@threadsParsed))
        
  describe "#threadFromMessageInfo", ->
    beforeEach ->
      threadsGetBatchResponse = fixture.load("gmail_api/users.threads.get.batch.fixture.json")[0]
      threadsResults = _.values(threadsGetBatchResponse.result)
      threadsInfo = _.pluck(threadsResults, "result")

      response = fixture.load("gmail_api/users.messages.get.batch.fixture.json")[0]
      @threadsParsed = fixture.load("gmail_api/users.threads.parsed.fixture.json")[0]

      threadInfo = _.find(threadsInfo, (threadInfo) =>
        return threadInfo.id == @threadsParsed[0].uid
      )
      lastMessage =_.last(threadInfo.messages)
      lastMessageResponse = response.result[lastMessage.id]
      @threadParsed = @emailThreadsCollection.threadFromMessageInfo(threadInfo, lastMessageResponse.result)
      
    it "parses the message into a thread", ->
      expect(JSON.stringify(@threadParsed)).toEqual(JSON.stringify(@threadsParsed[0]))
    
  describe "with models", ->
    beforeEach ->
      @emailThreadsCollection.add(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE))

    describe "Events", ->
      describe "#modelRemoved", ->
        beforeEach ->
          @emailThread = @emailThreadsCollection.at(0)
          @triggerStub = sinon.spy(@emailThread, "trigger")

          @emailThreadsCollection.remove(@emailThread)

        afterEach ->
          @triggerStub.restore()

        it "triggers removedFromCollection on the emailThread", ->
          expect(@triggerStub).toHaveBeenCalledWith("removedFromCollection", @emailThreadsCollection)

      describe "#modelsReset", ->
        beforeEach ->
          @modelRemovedStub = sinon.stub(@emailThreadsCollection, "modelRemoved", ->)

          @oldEmailThreads = @emailThreadsCollection.models
          @emailThreads = FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE)
          @emailThreadsCollection.reset(@emailThreads)

        afterEach ->
          @modelRemovedStub.restore()

        it "calls modelRemoved for each model model removed", ->
          for emailThread in @oldEmailThreads
            expect(@modelRemovedStub).toHaveBeenCalledWith(emailThread)

    describe "Setters", ->
      describe "#resetPageTokens", ->
        beforeEach ->
          @oldPageTokens = @emailThreadsCollection.pageTokens
          @oldPageTokenIndex = @emailThreadsCollection.pageTokenIndex
          
          @emailThreadsCollection.resetPageTokens()

        afterEach ->
          @emailThreadsCollection.pageTokenIndex = @oldPageTokenIndex
          @emailThreadsCollection.pageTokens = @oldPageTokens
        
        it "resets the page tokens", ->
          expect(@emailThreadsCollection.pageTokens).toEqual([null])
        
        it "resets the page token index", ->
          expect(@emailThreadsCollection.pageTokenIndex).toEqual(0)
          
      describe "#folderIDIs", ->
        beforeEach ->
          @resetPageTokensStub = sinon.stub(@emailThreadsCollection, "resetPageTokens", ->)
          @triggerStub = sinon.stub(@emailThreadsCollection, "trigger", ->)
          
        afterEach ->
          @triggerStub.restore()
          @resetPageTokensStub.restore()
          
        describe "folder ID is equal to the current folder ID", ->
          beforeEach ->
            @emailThreadsCollection.folderIDIs(@emailThreadsCollection.folderID)
            
          it "does not reset the page tokens", ->
            expect(@resetPageTokensStub).not.toHaveBeenCalled()
            
          it "triggers the change:pageTokenIndex event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:folderID", @emailThreadsCollection, @emailThreadsCollection.folderID)

        describe "folder ID is NOT equal to the current folder ID", ->
          beforeEach ->
            @emailThreadsCollection.folderIDIs("test")
            
          it "does not reset the page tokens", ->
            expect(@resetPageTokensStub).toHaveBeenCalled()

          it "triggers the change:folderID event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:folderID", @emailThreadsCollection, "test")
    
      describe "pageTokenIndexIs", ->
        beforeEach ->
          @triggerStub = sinon.stub(@emailThreadsCollection, "trigger", ->)

        afterEach ->
          @triggerStub.restore()
          
        describe "when the page token index is in range", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndexIs(0)
            
          it "updates the page token index", ->
            expect(@emailThreadsCollection.pageTokenIndex).toEqual(0)
        
          it "triggers the change:folderID event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:pageTokenIndex", @emailThreadsCollection, 0)
        
        describe "when the page token index is NOT in range", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndexIs(1)

          it "updates the page token index", ->
            expect(@emailThreadsCollection.pageTokenIndex).toEqual(0)

          it "triggers the change:folderID event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:pageTokenIndex", @emailThreadsCollection, 0)
            
    describe "Getters", ->
      describe "#getEmailThread", ->
        it "returns the email thread with the specified uid", ->
          for emailThread in @emailThreadsCollection.models
            retrievedEmailThread = @emailThreadsCollection.getEmailThread emailThread.get("uid")
            expect(emailThread).toEqual retrievedEmailThread
      
      describe "#hasNextPage", ->
        beforeEach ->
          @oldPageTokens = @emailThreadsCollection.pageTokens
          @oldPageTokenIndex = @emailThreadsCollection.pageTokenIndex

          @emailThreadsCollection.pageTokens = [null, "token"]
          
        afterEach ->
          @emailThreadsCollection.pageTokenIndex = @oldPageTokenIndex
          @emailThreadsCollection.pageTokens = @oldPageTokens
          
        describe "has a next page", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndex = 0
          
          it "returns true", ->
            expect(@emailThreadsCollection.hasNextPage()).toBeTruthy()

        describe "does NOT have a next page", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndex = 1

          it "returns false", ->
            expect(@emailThreadsCollection.hasNextPage()).toBeFalsy()

      describe "#hasPreviousPage", ->
        beforeEach ->
          @oldPageTokenIndex = @emailThreadsCollection.pageTokenIndex

        afterEach ->
          @emailThreadsCollection.pageTokenIndex = @oldPageTokenIndex

        describe "does NOT have a previous page", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndex = 0

          it "returns false", ->
            expect(@emailThreadsCollection.hasPreviousPage()).toBeFalsy()

        describe "has a previous page", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndex = 1

          it "returns true", ->
            expect(@emailThreadsCollection.hasPreviousPage()).toBeTruthy()
