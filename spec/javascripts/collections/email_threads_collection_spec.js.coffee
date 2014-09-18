describe "EmailThreads collection", ->

  beforeEach ->
    @emailThreadsCollection = new TuringEmailApp.Collections.EmailThreadsCollection(
      folder_id: "INBOX"
    )

  it "should exist", ->
    expect(TuringEmailApp.Collections.EmailThreadsCollection).toBeDefined()

  it "should use the EmailThread model", ->
      expect(@emailThreadsCollection.model).toEqual TuringEmailApp.Models.EmailThread

  it "should have the right url", ->
    expect(@emailThreadsCollection.url).toEqual '/api/v1/email_threads/in_folder?folder_id=INBOX'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("email_threads.fixture.json", true);

      @validEmailThreads = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email_threads/in_folder?folder_id=INBOX", JSON.stringify(@validEmailThreads)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @emailThreadsCollection.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/email_threads/in_folder?folder_id=INBOX"
      return

    it "should parse the attributes from the response", ->
      @emailThreadsCollection.fetch()
      @server.respond()

      expect(@emailThreadsCollection.length).toEqual @validEmailThreads.length
      expect(@emailThreadsCollection.toJSON()).toEqual @validEmailThreads
      return

    it "should have the attributes", ->
      @emailThreadsCollection.fetch()
      @server.respond()

      for emailThread in @emailThreadsCollection.models
        for email in emailThread.get("emails")
          expect(email.auto_filed).toBeDefined()
          expect(email.bccs).toBeDefined()
          expect(email.body_text).toBeDefined()
          expect(email.ccs).toBeDefined()
          expect(email.date).toBeDefined()
          expect(email.from_address).toBeDefined()
          expect(email.from_name).toBeDefined()
          expect(email.html_part).toBeDefined()
          expect(email.list_id).toBeDefined()
          expect(email.message_id).toBeDefined()
          expect(email.reply_to_address).toBeDefined()
          expect(email.reply_to_name).toBeDefined()
          expect(email.seen).toBeDefined()
          expect(email.sender_address).toBeDefined()
          expect(email.sender_name).toBeDefined()
          expect(email.snippet).toBeDefined()
          expect(email.subject).toBeDefined()
          expect(email.text_part).toBeDefined()
          expect(email.tos).toBeDefined()
          expect(email.uid).toBeDefined()

    describe "when getEmailThread is called", ->

      it "the correct email thread is returned", ->
        @emailThreadsCollection.fetch()
        @server.respond()

        for emailThread in @emailThreadsCollection.models
          retrievedEmailThread = @emailThreadsCollection.getEmailThread emailThread.get("uid")
          expect(emailThread).toEqual retrievedEmailThread
