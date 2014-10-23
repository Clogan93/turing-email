describe "EmailThread", ->
  beforeEach ->
    emailThreadAttributes = FactoryGirl.create("EmailThread")
    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
      app: TuringEmailApp
      emailThreadUID: emailThreadAttributes.uid
    )
    
    @emailThreads = FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE)
    
  describe "Class Methods", ->
    beforeEach ->
      @server = sinon.fakeServer.create()
      
    afterEach ->
      @server.restore()

    describe "#removeFromFolder", ->

      beforeEach ->
        @emailThreadUIDs = []
        for emailThread in @emailThreads
          @emailThreadUIDs.push emailThread.uid

        @emailFolderID = "INBOX"

      it "posts the emailThreadUIDs and the emailFolderID to the remove from folder API", ->
        TuringEmailApp.Models.EmailThread.removeFromFolder @emailThreadUIDs, @emailFolderID
        expect(@server.requests.length).toEqual 1
        request = @server.requests[0]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "/api/v1/email_threads/remove_from_folder"
        expect(request.requestBody).toEqual "email_thread_uids%5B%5D=1480ae36da1ba858&email_thread_uids%5B%5D=147f774efa8eb2e7&email_folder_id=INBOX"

    describe "#trash", ->

      beforeEach ->
        @emailThreadUIDs = []
        for emailThread in @emailThreads
          @emailThreadUIDs.push emailThread.uid

      it "posts the emailThreadUIDs to the trash API", ->
        TuringEmailApp.Models.EmailThread.trash @emailThreadUIDs
        expect(@server.requests.length).toEqual 1
        request = @server.requests[0]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "/api/v1/email_threads/trash"
        expect(request.requestBody).toEqual "email_thread_uids%5B%5D=1480ae36da1ba858&email_thread_uids%5B%5D=147f774efa8eb2e7"

    describe "#applyGmailLabel", ->

      beforeEach ->
        @emailThreadUIDs = []
        for emailThread in @emailThreads
          @emailThreadUIDs.push emailThread.uid

        emailFolder = FactoryGirl.create("EmailFolder")
        @labelID = emailFolder.label_id
        @labelName = emailFolder.name

      describe "when all the data is present", ->

        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          TuringEmailApp.Models.EmailThread.applyGmailLabel @emailThreadUIDs, @labelID, @labelName
          expect(@server.requests.length).toEqual 1
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/apply_gmail_label"
          expect(request.requestBody).toEqual "email_thread_uids%5B%5D=1480ae36da1ba858&email_thread_uids%5B%5D=147f774efa8eb2e7&gmail_label_id=Label_119&gmail_label_name=Mint"

      describe "when there is no label ID", ->

        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          TuringEmailApp.Models.EmailThread.applyGmailLabel @emailThreadUIDs, null, @labelName
          expect(@server.requests.length).toEqual 1
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/apply_gmail_label"
          expect(request.requestBody).toEqual "email_thread_uids%5B%5D=1480ae36da1ba858&email_thread_uids%5B%5D=147f774efa8eb2e7&gmail_label_name=Mint"

      describe "when there is no label name", ->

        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          TuringEmailApp.Models.EmailThread.applyGmailLabel @emailThreadUIDs, @labelID, null
          expect(@server.requests.length).toEqual 1
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/apply_gmail_label"
          expect(request.requestBody).toEqual "email_thread_uids%5B%5D=1480ae36da1ba858&email_thread_uids%5B%5D=147f774efa8eb2e7&gmail_label_id=Label_119"

    describe "#moveToFolder", ->

      beforeEach ->
        @emailThreadUIDs = []
        for emailThread in @emailThreads
          @emailThreadUIDs.push emailThread.uid

        emailFolder = FactoryGirl.create("EmailFolder")
        @folderID = emailFolder.label_id
        @folderName = emailFolder.name

      describe "when all the data is present", ->

        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          TuringEmailApp.Models.EmailThread.moveToFolder @emailThreadUIDs, @folderID, @folderName
          expect(@server.requests.length).toEqual 1
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/move_to_folder"
          expect(request.requestBody).toEqual "email_thread_uids%5B%5D=1480ae36da1ba858&email_thread_uids%5B%5D=147f774efa8eb2e7&email_folder_id=Label_119&email_folder_name=Mint"

      describe "when there is no label ID", ->

        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          TuringEmailApp.Models.EmailThread.moveToFolder @emailThreadUIDs, null, @folderName
          expect(@server.requests.length).toEqual 1
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/move_to_folder"
          expect(request.requestBody).toEqual "email_thread_uids%5B%5D=1480ae36da1ba858&email_thread_uids%5B%5D=147f774efa8eb2e7&email_folder_name=Mint"

      describe "when there is no label name", ->

        it "posts the emailThreadUIDs, the label ID and the label name to the apply gmail label API", ->
          TuringEmailApp.Models.EmailThread.moveToFolder @emailThreadUIDs, @folderID, null
          expect(@server.requests.length).toEqual 1
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_threads/move_to_folder"
          expect(request.requestBody).toEqual "email_thread_uids%5B%5D=1480ae36da1ba858&email_thread_uids%5B%5D=147f774efa8eb2e7&email_folder_id=Label_119"

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
        
        describe "without from_name", ->
          beforeEach ->
            @oldFromName = @emailThread.get("from_name")
            @emailThread.set("from_name", "")
  
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
