describe "EmailThread model", ->

  beforeEach ->
    @email_thread = new TuringEmailApp.Models.EmailThread()
    @email_thread.url = "/api/v1/email_threads"

  it "should exist", ->
    expect(TuringEmailApp.Models.EmailThread).toBeDefined()

  it "should have the right url", ->
    expect(@email_thread.url).toEqual '/api/v1/email_threads'

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
      @email_thread.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/email_threads"
      return

    it "should parse the attributes from the response", ->
      @email_thread.fetch()
      @server.respond()

      expect(@email_thread.get("emails")).toEqual @validEmailThread.emails
      expect(@email_thread.get("uid")).toEqual @validEmailThread.uid
      return

    it "should have the attributes", ->
      @email_thread.fetch()
      @server.respond()

      expect(@email_thread.get("uid")).toBeDefined()
      expect(@email_thread.get("emails")).toBeDefined()
      for email in @email_thread.get("emails")
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
