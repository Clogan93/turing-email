describe "EmailFoldersCollection", ->
  beforeEach ->
    @emailFoldersCollection = new TuringEmailApp.Collections.EmailFoldersCollection(undefined, app: TuringEmailApp)

  it "should use the EmailFolder model", ->
    expect(@emailFoldersCollection.model).toEqual TuringEmailApp.Models.EmailFolder
    
  describe "Network", ->
    describe "#sync", ->
      beforeEach ->
        @superStub = sinon.stub(TuringEmailApp.Collections.EmailFoldersCollection.__super__, "sync")
        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
  
      afterEach ->
        @googleRequestStub.restore()
        @superStub.restore()
        
      describe "write", ->
        beforeEach ->
          @method = "write"
          @model = {}
          @options = {}
          
          @emailFoldersCollection.sync(@method, @model, @options)
          
        it "calls super", ->
          expect(@superStub).toHaveBeenCalledWith(@method, @model, @options)
          
        it "does NOT call googleRequest", ->
          expect(@googleRequestStub).not.toHaveBeenCalled()
        
      describe "read", ->
        beforeEach ->
          @error = sinon.stub()
          @emailFoldersCollection.sync("read", {}, error: @error)
  
        it "does not call super", ->
          expect(@superStub).not.toHaveBeenCalled()
          
        it "calls googleRequest", ->
          expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
          specCompareFunctions((=> @labelsListRequest()), @googleRequestStub.args[0][1])
          specCompareFunctions(((response) => @loadLabels(response.result.labels, options)), @googleRequestStub.args[0][2])
          expect(@googleRequestStub.args[0][3]).toEqual(@error)

    describe "#labelsListRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: labels: list: ->
        
        @ret = {}
        @labelsListStub = sinon.stub(gapi.client.gmail.users.labels, "list", => return @ret)

        @returned = @emailFoldersCollection.labelsListRequest()
      
      afterEach ->
        @labelsListStub.restore()
        
      it "prepares and returns the Gmail API request", ->
        expect(@labelsListStub).toHaveBeenCalledWith(userId: "me", fields: "labels/id")
        expect(@returned).toEqual(@ret)

    describe "#loadLabels", ->
      beforeEach ->
        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
        labelsListInfo = fixture.load("gmail_api/users.labels.list.fixture.json")[0]
        
        @error = sinon.stub()
        @emailFoldersCollection.loadLabels(labelsListInfo, error: @error)

      afterEach ->
        @googleRequestStub.restore()

      it "calls googleRequest", ->
        expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
        specCompareFunctions((=> @labelsGetBatch(labelsListInfo)), @googleRequestStub.args[0][1])
        specCompareFunctions(((response) => @processLabelsGetBatch(response, options)), @googleRequestStub.args[0][2])
        expect(@googleRequestStub.args[0][3]).toEqual(@error)

    describe "#labelsGetBatch", ->
      beforeEach ->
        @batch = add: =>
        @addStub = sinon.stub(@batch, "add", =>)
        
        window.gapi =
          client:
            newBatch: => @batch
              
            gmail: 
              users: 
                labels: get: ->

        @labelsGetStub = sinon.stub(gapi.client.gmail.users.labels, "get", (params) => params)

        @labelsListInfo = fixture.load("gmail_api/users.labels.list.fixture.json")[0]
        @returned = @emailFoldersCollection.labelsGetBatch(@labelsListInfo)
        
      it "adds the items to the batch", ->
        for labelInfo in @labelsListInfo
          params = userId: "me", id: labelInfo.id

          expect(@labelsGetStub).toHaveBeenCalledWith(params)
          expect(@addStub).toHaveBeenCalledWith(params)
        
      it "returns the batch", ->
        expect(@returned).toEqual(@batch)
      
    describe "#processLabelsGetBatch", ->
      beforeEach ->
        response = fixture.load("gmail_api/users.labels.get.batch.fixture.json")[0]
        labelsResults = _.values(response.result)
        @labelsInfo = _.pluck(labelsResults, "result")
        
        @success = sinon.stub()
        @emailFoldersCollection.processLabelsGetBatch(response, success: @success)
        
      it "calls success option with the labelsInfo", ->
        expect(@success).toHaveBeenCalledWith(@labelsInfo)
        
    describe "#parse", ->
      beforeEach ->
        labelsInfo = fixture.load("gmail_api/users.labels.get.fixture.json")[0]
        @labelsParsed = fixture.load("gmail_api/users.labels.parsed.fixture.json")[0]
        
        @returned = @emailFoldersCollection.parse(labelsInfo)

      it "returns the parsed labels", ->
        expect(@returned).toEqual(@labelsParsed)
        
  describe "with models", ->
    beforeEach ->
      @emailFoldersCollection.add(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))

    describe "Events", ->
      describe "#modelRemoved", ->
        beforeEach ->
          @emailFolder = @emailFoldersCollection.at(0)
          @triggerStub = sinon.spy(@emailFolder, "trigger")
          
          @emailFoldersCollection.remove(@emailFolder)
          
        afterEach ->
          @triggerStub.restore()
          
        it "triggers removedFromCollection on the emailFolder", ->
          expect(@triggerStub).toHaveBeenCalledWith("removedFromCollection", @emailFoldersCollection)
  
      describe "#modelsReset", ->
        beforeEach ->
          @modelRemovedStub = sinon.stub(@emailFoldersCollection, "modelRemoved", ->)
          
          @oldEmailFolders = @emailFoldersCollection.models
          @emailFolders = FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE)
          @emailFoldersCollection.reset(@emailFolders)
          
        afterEach ->
          @modelRemovedStub.restore()
          
        it "calls modelRemoved for each model model removed", ->
          for emailFolder in @oldEmailFolders
            expect(@modelRemovedStub).toHaveBeenCalledWith(emailFolder)
            
    describe "Getters", ->
      describe "#getEmailFolder", ->
        it "returns the email folder with the specified label_id", ->
          for emailFolder in @emailFoldersCollection.models
            retrievedEmailFolder = @emailFoldersCollection.getEmailFolder(emailFolder.get("label_id"))
            expect(emailFolder).toEqual retrievedEmailFolder
