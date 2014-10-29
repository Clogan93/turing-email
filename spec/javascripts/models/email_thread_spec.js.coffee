describe "EmailThread", ->
  beforeEach ->
    emailThreadAttributes = FactoryGirl.create("EmailThread")
    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
      app: TuringEmailApp
      emailThreadUID: emailThreadAttributes.uid
    )
    
    @emailThreads = FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE)

  it "uses uid as idAttribute", ->
    expect(@emailThread.idAttribute).toEqual("uid")

  describe "Class Methods", ->
    beforeEach ->
      @server = sinon.fakeServer.create()

      @emailThreadUIDs = (emailThread.uid for emailThread in @emailThreads)
      @requestBody = "email_thread_uids%5B%5D=" + @emailThreadUIDs.join("&email_thread_uids%5B%5D=")
      
    afterEach ->
      @server.restore()

    describe "#setThreadParsedProperties", ->
      beforeEach ->
        @server.restore()
        @response = fixture.load("gmail_api/users.threads.get.fixture.json")[0]
        @threadMinParsed = fixture.load("gmail_api/users.thread.min.parsed.fixture.json")[0]
        @server = sinon.fakeServer.create()
        
        @threadInfo = @response.result
        @result = TuringEmailApp.Models.EmailThread.setThreadParsedProperties(uid: @threadInfo.id,
                                                                              @threadInfo.messages,
                                                                              @threadInfo.messages[0])
      
      it "sets the thread properties", ->
        expect(JSON.stringify(@result)).toEqual(JSON.stringify(@threadMinParsed))
      
    describe "#removeFromFolder", ->
      beforeEach ->
        @emailFolderID = "INBOX"
        @requestBody += "&email_folder_id=" + @emailFolderID

        TuringEmailApp.Models.EmailThread.removeFromFolder(@emailThreadUIDs, @emailFolderID)

      it "posts the emailThreadUIDs and the emailFolderID to the remove from folder API", ->
        expect(@server.requests.length).toEqual 1
        
        request = @server.requests[0]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "/api/v1/email_threads/remove_from_folder"
        expect(request.requestBody).toEqual(@requestBody)

    describe "#trash", ->
      beforeEach ->
        TuringEmailApp.Models.EmailThread.trash @emailThreadUIDs
        
      it "posts the emailThreadUIDs to the trash API", ->
        expect(@server.requests.length).toEqual 1
        
        request = @server.requests[0]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "/api/v1/email_threads/trash"
        expect(request.requestBody).toEqual(@requestBody) 

    describe "#applyGmailLabel", ->
      beforeEach ->
        emailFolder = FactoryGirl.create("EmailFolder")
        @labelID = emailFolder.label_id
        @labelName = emailFolder.name
        
      describe "when all the data is present", ->
        beforeEach ->
          @requestBody += "&gmail_label_id=" + @labelID + "&gmail_label_name=" + @labelName
          TuringEmailApp.Models.EmailThread.applyGmailLabel @emailThreadUIDs, @labelID, @labelName
          
        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          expect(@server.requests.length).toEqual 1
          
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/apply_gmail_label"
          expect(request.requestBody).toEqual(@requestBody)

      describe "when there is no label ID", ->
        beforeEach ->
          @requestBody += "&gmail_label_name=" + @labelName
          TuringEmailApp.Models.EmailThread.applyGmailLabel @emailThreadUIDs, null, @labelName
        
        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          expect(@server.requests.length).toEqual 1
          
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/apply_gmail_label"
          expect(request.requestBody).toEqual(@requestBody)

      describe "when there is no label name", ->
        beforeEach ->
          @requestBody += "&gmail_label_id=" + @labelID
          TuringEmailApp.Models.EmailThread.applyGmailLabel @emailThreadUIDs, @labelID, null
          
        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          expect(@server.requests.length).toEqual 1
          
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/apply_gmail_label"
          expect(request.requestBody).toEqual(@requestBody)

    describe "#moveToFolder", ->
      beforeEach ->
        emailFolder = FactoryGirl.create("EmailFolder")
        @folderID = emailFolder.label_id
        @folderName = emailFolder.name

      describe "when all the data is present", ->
        beforeEach ->
          @requestBody += "&email_folder_id=" + @folderID + "&email_folder_name=" + @folderName
          TuringEmailApp.Models.EmailThread.moveToFolder @emailThreadUIDs, @folderID, @folderName
        
        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          expect(@server.requests.length).toEqual 1
          
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/move_to_folder"
          expect(request.requestBody).toEqual(@requestBody)

      describe "when there is no label ID", ->
        beforeEach ->
          @requestBody += "&email_folder_name=" + @folderName
          TuringEmailApp.Models.EmailThread.moveToFolder @emailThreadUIDs, null, @folderName
          
        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          expect(@server.requests.length).toEqual 1
          
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/move_to_folder"
          expect(request.requestBody).toEqual(@requestBody)
          
      describe "when there is no label name", ->
        beforeEach ->
          @requestBody += "&email_folder_id=" + @folderID
          TuringEmailApp.Models.EmailThread.moveToFolder @emailThreadUIDs, @folderID, null

        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          expect(@server.requests.length).toEqual 1
          
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/move_to_folder"
          expect(request.requestBody).toEqual(@requestBody)

  describe "#initialize", ->
    beforeEach ->
      @emailThreadTemp = new TuringEmailApp.Models.EmailThread(undefined,
        app: TuringEmailApp
        emailThreadUID: "1"
      )

    it "initializes the variables", ->
      expect(@emailThreadTemp.app).toEqual(TuringEmailApp)
      expect(@emailThreadTemp.emailThreadUID).toEqual("1")

  describe "Network", ->
    describe "#load", ->
      beforeEach ->
        @success = sinon.stub()
        @error = sinon.stub()
        @options = success: @success, error: @error
        @fetchStub = sinon.stub(@emailThread, "fetch")
        
        @checkFetch = =>
          expect(@emailThread.loading).toBeTruthy()
          expect(@emailThread.emailThreadUID).toEqual(@emailThread.get("uid"))
          expect(@fetchStub).toHaveBeenCalled()
          
        @checkSuccess = =>
          expect(@emailThread.get("loaded")).toBeTruthy()
          expect(@emailThread.loading).toBeFalsy()
          expect(@success).toHaveBeenCalled()
          expect(@error).not.toHaveBeenCalled()
          
        @checkError = =>
          expect(@emailThread.get("loaded")).toBeFalsy()
          expect(@emailThread.loading).toBeFalsy()
          expect(@success).not.toHaveBeenCalled()
          expect(@error).toHaveBeenCalled()
        
      afterEach ->
        @fetchStub.restore()
        
      describe "loaded=true", ->
        beforeEach ->
          @emailThread.set("loaded", true)

        describe "force=false", ->
          beforeEach ->
            @emailThread.load(@options)
            
          it "calls success", ->
            expect(@options.success).toHaveBeenCalled()
            
          it "does not fetch", ->
            expect(@fetchStub).not.toHaveBeenCalled()
            
        describe "force=true", ->
          describe "loading=true", ->
            beforeEach ->
              @emailThread.loading = true
              @emailThread.load(@options, true)
              
            it "returns", ->
              expect(@success).not.toHaveBeenCalled()
              expect(@error).not.toHaveBeenCalled()
              expect(@fetchStub).not.toHaveBeenCalled()
            
          describe "loading=false", ->
            beforeEach ->
              @emailThread.loading = false
              @emailThread.load(@options, true)
              
            it "fetches", ->
              @checkFetch()
              
            describe "on success", ->
              beforeEach ->
                @fetchStub.args[0][0].success()
                
              it "loads", ->
                @checkSuccess()
                
            describe "on error", ->
              beforeEach ->
                @emailThread.set("loaded", false)
                @fetchStub.args[0][0].error()

              it "errors", ->
                @checkError()
    
      describe "loaded=false", ->
        beforeEach ->
          @emailThread.set("loaded", false)
          
        describe "loading=true", ->
          beforeEach ->
            @emailThread.loading = true
            @emailThread.load(@options)

          it "returns", ->
            expect(@success).not.toHaveBeenCalled()
            expect(@error).not.toHaveBeenCalled()
            expect(@fetchStub).not.toHaveBeenCalled()

        describe "loading=false", ->
          beforeEach ->
            @emailThread.loading = false
            @emailThread.load(@options)

          it "fetches", ->
            @checkFetch()

          describe "on success", ->
            beforeEach ->
              @fetchStub.args[0][0].success()

            it "loads", ->
              @checkSuccess()

          describe "on error", ->
            beforeEach ->
              @emailThread.set("loaded", false)
              @fetchStub.args[0][0].error()

            it "errors", ->
              @checkError()
      
    describe "#sync", ->
      beforeEach ->
        @superStub = sinon.stub(TuringEmailApp.Models.EmailThread.__super__, "sync")
        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
        @triggerStub = sinon.stub(@emailThread, "trigger", ->)
  
      afterEach ->
        @triggerStub.restore()
        @googleRequestStub.restore()
        @superStub.restore()
  
      describe "write", ->
        beforeEach ->
          @method = "write"
          @model = {}
          @options = {}

          @emailThread.sync(@method, @model, @options)
  
        it "calls super", ->
          expect(@superStub).toHaveBeenCalledWith(@method, @model, @options)
  
        it "does NOT call googleRequest", ->
          expect(@googleRequestStub).not.toHaveBeenCalled()
          
        it "does not trigger the request event", ->
          expect(@triggerStub).not.toHaveBeenCalled()
  
      describe "read", ->
        beforeEach ->
          @model = {}
          @options = error: sinon.stub()
          @emailThread.sync("read", @model, @options)
  
        it "does not call super", ->
          expect(@superStub).not.toHaveBeenCalled()
  
        it "calls googleRequest", ->
          expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
          specCompareFunctions((=> @threadsGetRequest()), @googleRequestStub.args[0][1])
          specCompareFunctions(((response) => @processThreadsGetRequest(response, options)), @googleRequestStub.args[0][2])
          expect(@googleRequestStub.args[0][3]).toEqual(@options.error)

        it "triggers the request event", ->
          expect(@triggerStub).toHaveBeenCalledWith("request", @model, null, @options)
      
    describe "#threadsGetRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: threads: get: ->

        @ret = {}
        @threadsGetStub = sinon.stub(gapi.client.gmail.users.threads, "get", => return @ret)

        @params =
          userId: "me"
          id: @emailThread.emailThreadUID

      afterEach ->
        @threadsGetStub.restore()

      it "prepares and returns the Gmail API request", ->
        @returned = @emailThread.threadsGetRequest()

        expect(@threadsGetStub).toHaveBeenCalledWith(@params)
        expect(@returned).toEqual(@ret)
          
    describe "#processThreadsGetRequest", ->
      beforeEach ->
        @response = fixture.load("gmail_api/users.threads.get.fixture.json")[0]
        @options = {success: sinon.stub()}

        @threadJSON = {}
        @parseThreadInfoStub = sinon.stub(@emailThread, "parseThreadInfo", => @threadJSON)
        
        @emailThread.processThreadsGetRequest(@response, @options)
    
      afterEach ->
        @parseThreadInfoStub.restore()
        
      it "parse the response", ->
        expect(@parseThreadInfoStub).toHaveBeenCalledWith(@response.result)
        
      it "passes the result of parseThreadInfo to the success handler", ->
        expect(@options.success).toHaveBeenCalledWith(@threadJSON)
        
    describe "#parseThreadInfo", ->
      beforeEach ->
        @response = fixture.load("gmail_api/users.threads.get.fixture.json")[0]
        @threadInfo = @response.result

        @threadParsed = fixture.load("gmail_api/users.thread.parsed.fixture.json")[0]
        @result = @emailThread.parseThreadInfo(@threadInfo)
        
      it "parses the thread", ->
        expect(JSON.stringify(@result)).toEqual(JSON.stringify(@threadParsed))
        
  describe "Events", ->
    describe "#threadsModifyUnreadRequest", ->
      beforeEach ->
        window.gapi = client: gmail: users: threads: modify: ->

        @ret = {}
        @threadsModifyStub = sinon.stub(gapi.client.gmail.users.threads, "modify", => return @ret)

        @params =
          userId: "me"
          id: @emailThread.get("uid")

      afterEach ->
        @threadsModifyStub.restore()

      describe "seenValue=true", ->
        beforeEach ->
          @body = removeLabelIds: ["UNREAD"]
          @returned = @emailThread.threadsModifyUnreadRequest(true)
          
        it "prepares and returns the Gmail API request", ->
          expect(@threadsModifyStub).toHaveBeenCalledWith(@params, @body)
          expect(@returned).toEqual(@ret)

      describe "seenValue=false", ->
        beforeEach ->
          @body = addLabelIds: ["UNREAD"]
          @returned = @emailThread.threadsModifyUnreadRequest(false)

        it "prepares and returns the Gmail API request", ->
          expect(@threadsModifyStub).toHaveBeenCalledWith(@params, @body)
          expect(@returned).toEqual(@ret)
      
    describe "#seenChanged", ->
      beforeEach ->
        @googleRequestStub = sinon.stub(window, "googleRequest", ->)
        @emailThread.set("seen", !@emailThread.get("seen"))
        
      afterEach ->
        @googleRequestStub.restore()

      it "calls googleRequest", ->
        expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
        specCompareFunctions((=> @threadsModifyUnreadRequest(seenValue)), @googleRequestStub.args[0][1])
          
  describe "Getters", ->
    describe "#sortedEmails", ->
      beforeEach ->
        @sortedEmails = @emailThread.get("emails").sort (a, b) -> a.date - b.date

      it "returns the emails sorted by date", ->
        expect(@emailThread.sortedEmails()).toEqual(@sortedEmails)
  
  describe "Actions", ->
    describe "#removeFromFolder", ->
      beforeEach ->
        emailFolder = FactoryGirl.create("EmailFolder")
        @folderID = emailFolder.label_id
  
      it "calls the remove from folder class method", ->
        spy = sinon.spy(TuringEmailApp.Models.EmailThread, "removeFromFolder")
        @emailThread.removeFromFolder @folderID
  
        expect(spy).toHaveBeenCalledWith [@emailThread.get("uid")], @folderID
        spy.restore()
  
    describe "#trash", ->
      it "calls the remove from folder class method", ->
        spy = sinon.spy(TuringEmailApp.Models.EmailThread, "trash")
        @emailThread.trash()
  
        expect(spy).toHaveBeenCalledWith [@emailThread.get("uid")]
        spy.restore()
  
    describe "#applyGmailLabel", ->
      beforeEach ->
        emailFolder = FactoryGirl.create("EmailFolder")
        @labelID = emailFolder.label_id
        @labelName = emailFolder.name
  
      it "calls the apply gmail label class method", ->
        spy = sinon.spy(TuringEmailApp.Models.EmailThread, "applyGmailLabel")
        @emailThread.applyGmailLabel @labelID, @labelName
  
        expect(spy).toHaveBeenCalledWith [@emailThread.get("uid")], @labelID, @labelName
        spy.restore()
  
    describe "#moveToFolder", ->
      beforeEach ->
        emailFolder = FactoryGirl.create("EmailFolder")
        @folderID = emailFolder.label_id
        @folderName = emailFolder.name
  
      it "calls the move to folder class method", ->
        spy = sinon.spy(TuringEmailApp.Models.EmailThread, "moveToFolder")
        @emailThread.moveToFolder @folderID, @folderName
  
        expect(spy).toHaveBeenCalledWith [@emailThread.get("uid")], @folderID, @folderName
        spy.restore()

  describe "Formatters", ->
    beforeEach ->
      specStartTuringEmailApp()

      TuringEmailApp.models.user = new TuringEmailApp.Models.User(FactoryGirl.create("User"))
      
    afterEach ->
      specStopTuringEmailApp()

    describe "#numEmailsText", ->
      describe "with emails", ->
        describe "with 1 email", ->
          beforeEach ->
            @emailThread.set("emails", [null])

          it "returns an empty string", ->
            expect(@emailThread.numEmailsText()).toEqual ""

        describe "more than 1 email", ->
          beforeEach ->
            @emailThread.set("emails", [null, null])

          it "returns the preview text", ->
            expect(@emailThread.numEmailsText()).toEqual "(2)"

      describe "without emails", ->
        beforeEach ->
          @emailThread.set("emails", null)
  
        describe "with 1 email", ->
          beforeEach ->
            @emailThread.set("num_messages", 1)
            
          it "returns an empty string", ->
            expect(@emailThread.numEmailsText()).toEqual ""
  
        describe "more than 1 email", ->
          beforeEach ->
            @emailThread.set("num_messages", 2)
            
          it "returns the preview text", ->
            expect(@emailThread.numEmailsText()).toEqual "(2)"

    describe "#fromPreview", ->
      describe "from_address is the user's email", ->
        beforeEach ->
          @oldFromAddress = @emailThread.get("from_address")
          @emailThread.set("from_address", TuringEmailApp.models.user.get("email"))
          
        afterEach ->
          @emailThread.set("from_address", @oldFromAddress)
      
        it "returns the correct preview", ->
          expect(@emailThread.fromPreview()).toEqual("me " + @emailThread.numEmailsText())
      
      describe "from_address is NOT the user's email", ->
        describe "with from_name", ->
          it "returns the correct preview", ->
            expect(@emailThread.fromPreview()).toEqual(@emailThread.get("from_name") + " " + @emailThread.numEmailsText())
        
        describe "with from_name=blank", ->
          beforeEach ->
            @oldFromName = @emailThread.get("from_name")
            @emailThread.set("from_name", "")
  
          afterEach ->
            @emailThread.set("from_name", @oldFromName)
            
          it "returns the correct preview", ->
            expect(@emailThread.fromPreview()).toEqual(@emailThread.get("from_address") + " " + @emailThread.numEmailsText())

        describe "with from_name=null", ->
          beforeEach ->
            @oldFromName = @emailThread.get("from_name")
            @emailThread.set("from_name", null)

          afterEach ->
            @emailThread.set("from_name", @oldFromName)

          it "returns the correct preview", ->
            expect(@emailThread.fromPreview()).toEqual(@emailThread.get("from_address") + " " + @emailThread.numEmailsText())
            
    describe "#subjectPreview", ->
      describe "has a subject", ->
        it "returns the correct subject preview", ->
          expect(@emailThread.subjectPreview()).toEqual(@emailThread.get("subject"))
        
      describe "no subject", ->
        beforeEach ->
          @oldSubject = @emailThread.get("subject")
          @emailThread.set("subject", "")
        
        afterEach ->
          @emailThread.set("subject", @oldSubject)
          
        it "returns the correct subject preview", ->
          expect(@emailThread.subjectPreview()).toEqual("(no subject)")

    describe "#datePreview", ->
      it "returns the localized date string", ->
        expect(@emailThread.datePreview()).toEqual(TuringEmailApp.Models.Email.localDateString(@emailThread.get("date")))
