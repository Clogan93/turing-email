describe "EmailThread model", ->

  beforeEach ->
    @emailThread = new TuringEmailApp.Models.EmailThread()
    @emailThread.url = "/api/v1/email_threads"

  it "should exist", ->
    expect(TuringEmailApp.Models.EmailThread).toBeDefined()

  it "should have the right url", ->
    expect(@emailThread.url).toEqual '/api/v1/email_threads'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("email_thread.fixture.json", true);

      @validEmailThread = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email_threads", JSON.stringify(@validEmailThread)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @emailThread.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/email_threads"
      return

    it "should parse the attributes from the response", ->
      @emailThread.fetch()
      @server.respond()

      expect(@emailThread.get("emails")).toEqual @validEmailThread.emails
      expect(@emailThread.get("uid")).toEqual @validEmailThread.uid
      return

    it "should have the attributes", ->
      @emailThread.fetch()
      @server.respond()

      expect(@emailThread.get("uid")).toBeDefined()
      expect(@emailThread.get("emails")).toBeDefined()
      for email in @emailThread.get("emails")
        expect(email.auto_filed).toBeDefined()
        expect(email.uid).toBeDefined()
        expect(email.message_id).toBeDefined()
        expect(email.list_id).toBeDefined()
        expect(email.seen).toBeDefined()
        expect(email.snippet).toBeDefined()
        expect(email.date).toBeDefined()

        expect(email.from_name).toBeDefined()
        expect(email.from_address).toBeDefined()
        expect(email.sender_name).toBeDefined()
        expect(email.sender_address).toBeDefined()
        expect(email.reply_to_name).toBeDefined()
        expect(email.reply_to_address).toBeDefined()

        expect(email.tos).toBeDefined()
        expect(email.ccs).toBeDefined()
        expect(email.bccs).toBeDefined()
        expect(email.subject).toBeDefined()
        expect(email.html_part).toBeDefined()
        expect(email.text_part).toBeDefined()
        expect(email.body_text).toBeDefined()
