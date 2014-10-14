describe "EmailThread", ->
  beforeEach ->
    emailThreadFixtures = fixture.load("email_thread.fixture.json")
    @validEmailThreadFixture = emailThreadFixtures[0]["valid"]

    emailThreadsFixtures = fixture.load("email_threads.fixture.json", true)
    @validEmailThreadsFixture = emailThreadsFixtures[0]["valid"]

    emailFoldersFixtures = fixture.load("email_folders.fixture.json", true)
    @validEmailFoldersFixture = emailFoldersFixtures[0]["valid"]

    @userFixtures = fixture.load("user.fixture.json", true)

    @emailThread = new TuringEmailApp.Models.EmailThread(undefined, emailThreadUID: @validEmailThreadFixture["uid"])

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_threads/show/" + @validEmailThreadFixture["uid"]
    @server.respondWith "GET", @url, JSON.stringify(@validEmailThreadFixture)
    
  afterEach ->
    @server.restore()

  it "has the right url", ->
    expect(@emailThread.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()
      
    it "loads the email thread", ->
      validateEmailThreadAttributes(@emailThread.toJSON())
  
      for email in @emailThread.get("emails")
        validateEmailAttributes(email)

  describe "Class Methods", ->

    describe "#removeFromFolder", ->

      beforeEach ->
        @emailThreadUIDs = []
        for emailThread in @validEmailThreadsFixture
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
        for emailThread in @validEmailThreadsFixture
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
        for emailThread in @validEmailThreadsFixture
          @emailThreadUIDs.push emailThread.uid

        emailFolder = @validEmailFoldersFixture[8]
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
        for emailThread in @validEmailThreadsFixture
          @emailThreadUIDs.push emailThread.uid

        emailFolder = @validEmailFoldersFixture[8]
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

  describe "Instance Methods", ->

    describe "#seenIs", ->
      beforeEach ->
        @emailThread.fetch()
        @server.respond()
        
        @setSeenURL = "/api/v1/emails/set_seen"
        @server.respondWith "POST", @setSeenURL, JSON.stringify({})

        @emailUIDs = (email["uid"] for email in @validEmailThreadFixture["emails"])
        @emailUIDs.sort()

      describe "seenValue=true", ->
        beforeEach ->
          email.seen = false for email in @emailThread.get("emails")
          
          @emailThread.seenIs(true)
          @server.respond()

        it "sets seen to true", ->
          expect(@server.requests.length).toEqual 2
          request = @server.requests[1]
          
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual @setSeenURL
          
          postData = $.unserialize(request.requestBody)
          expect(postData["seen"]).toEqual("true")
          expect(postData["email_uids"].sort()).toEqual(@emailUIDs)

          for email in @emailThread.get("emails")
            expect(email.seen).toBeTruthy()

      describe "seenValue=false", ->
        beforeEach ->
          email.seen = true for email in @emailThread.get("emails")
          
          @emailThread.seenIs(false)
          @server.respond()

        it "sets seen to false", ->
          expect(@server.requests.length).toEqual 2
          request = @server.requests[1]
          
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual @setSeenURL

          postData = $.unserialize(request.requestBody)
          expect(postData["seen"]).toEqual("false")
          expect(postData["email_uids"].sort()).toEqual(@emailUIDs)

          for email in @emailThread.get("emails")
            expect(email.seen).toBeFalsy()

    describe "#removeFromFolder", ->
      beforeEach ->
        @emailThread.fetch()
        @server.respond()

        emailFolder = @validEmailFoldersFixture[8]
        @folderID = emailFolder.label_id

      it "calls the remove from folder class method", ->
        spy = sinon.spy(TuringEmailApp.Models.EmailThread, "removeFromFolder")
        @emailThread.removeFromFolder @folderID
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith [@emailThread.get("uid")], @folderID

    describe "#trash", ->
      beforeEach ->
        @emailThread.fetch()
        @server.respond()

      it "calls the remove from folder class method", ->
        spy = sinon.spy(TuringEmailApp.Models.EmailThread, "trash")
        @emailThread.trash()
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith [@emailThread.get("uid")]

    describe "#applyGmailLabel", ->
      beforeEach ->
        @emailThread.fetch()
        @server.respond()

        emailFolder = @validEmailFoldersFixture[8]
        @labelID = emailFolder.label_id
        @labelName = emailFolder.name

      it "calls the apply gmail label class method", ->
        spy = sinon.spy(TuringEmailApp.Models.EmailThread, "applyGmailLabel")
        @emailThread.applyGmailLabel @labelID, @labelName
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith [@emailThread.get("uid")], @labelID, @labelName

    describe "#moveToFolder", ->
      beforeEach ->
        @emailThread.fetch()
        @server.respond()

        emailFolder = @validEmailFoldersFixture[8]
        @folderID = emailFolder.label_id
        @folderName = emailFolder.name

      it "calls the move to folder class method", ->
        spy = sinon.spy(TuringEmailApp.Models.EmailThread, "moveToFolder")
        @emailThread.moveToFolder @folderID, @folderName
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith [@emailThread.get("uid")], @folderID, @folderName

    describe "#folderIDs", ->
      beforeEach ->
        @server.restore()
        
        [@server, @emailThread, validEmailThreadFixture] = specPrepareEmailThreadFetch()
        @emailThread.fetch()
        @server.respond()

        folderIDsMap = []
        
        for email in validEmailThreadFixture["emails"]
          folderIDsMap[gmailLabel["label_id"]] = null for gmailLabel in email["gmail_labels"] if email["gmail_labels"]?
          folderIDsMap[imapFolder["folder_id"]] = null for imapFolder in email["imap_folders"] if email["imap_folders"]?
          
        @folderIDs = _.keys(folderIDsMap).sort()
        expect(@folderIDs.length > 0).toBeTruthy()

      afterEach ->
        @server.restore()

      it "returns the folder IDs", ->
        expect(@emailThread.folderIDs().sort()).toEqual(@folderIDs)

    describe "Formatters", ->
      beforeEach ->
        specStartTuringEmailApp()
        
        @validUserFixture = @userFixtures[0]["valid"]

        @server.respondWith "GET", TuringEmailApp.models.user.url, JSON.stringify(@validUserFixture)

        @emailThread.fetch()
        @server.respond()

        TuringEmailApp.models.user.fetch()
        @server.respond()
        
      afterEach ->
        specStopTuringEmailApp()

      describe "#fromPreview", ->

        it "returns the correct response under default conditions", ->
          expect(@emailThread.fromPreview()).toEqual("David Gobaud")

        it "returns the correct response when the most recent email sent from the user", ->
          @emailThread.get("emails")[0]["from_address"] = TuringEmailApp.models.user.get("email")
          @emailThread.get("emails")[1]["from_name"] = "Joe Blogs"
          expect(@emailThread.fromPreview()).toEqual("Joe Blogs, me")

        it "returns the correct response when the most recent email sent from the user and there is only one email", ->
          @emailThread.get("emails")[0]["from_address"] = TuringEmailApp.models.user.get("email")
          @emailThread.get("emails").pop()
          expect(@emailThread.fromPreview()).toEqual("me")

      describe "#subjectPreview", ->

        it "returns the correct response under default conditions", ->
          expect(@emailThread.subjectPreview()).toEqual("Re: [turing-email] clicking thread message to expand it on first load doesnt work (#62)")

        it "returns the correct response when the most recent email sent from the user", ->
          @emailThread.get("emails")[0]["from_address"] = TuringEmailApp.models.user.get("email")
          expect(@emailThread.subjectPreview()).toEqual("[turing-email] clicking thread message to expand it on first load doesnt work (#62)")

        it "returns the correct response when the most recent email sent from the user and there is only one email", ->
          @emailThread.get("emails")[0]["from_address"] = TuringEmailApp.models.user.get("email")
          @emailThread.get("emails").pop()
          expect(@emailThread.subjectPreview()).toEqual("Re: [turing-email] clicking thread message to expand it on first load doesnt work (#62)")

      describe "#datePreview", ->

        it "returns the correct response under default conditions", ->
          expect(@emailThread.datePreview()).toEqual("Aug 24")

        describe "when there are no emails", ->
          beforeEach ->
            console.log @emailThread.attributes.emails = []

          it "returns a blank string", ->
            expect(@emailThread.datePreview()).toEqual("")
