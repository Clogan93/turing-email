describe "Email model", ->

  beforeEach ->
    @email = new TuringEmailApp.Models.Email()
    @email.url = "/api/v1/email"

  it "should exist", ->
    expect(TuringEmailApp.Models.Email).toBeDefined()

  it "should have the right url", ->
    expect(@email.url).toEqual '/api/v1/email'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("email.fixture.json", true);

      @validEmail = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email", JSON.stringify(@validEmail)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @email.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/email"
      return

    it "should parse the attributes from the response", ->
      @email.fetch()
      @server.respond()

      expect(@email.get("auto_filed")).toEqual @validEmail.auto_filed
      expect(@email.get("bccs")).toEqual @validEmail.bccs
      expect(@email.get("body_text")).toEqual @validEmail.body_text
      expect(@email.get("ccs")).toEqual @validEmail.ccs
      expect(@email.get("date")).toEqual @validEmail.date
      expect(@email.get("from_address")).toEqual @validEmail.from_address
      expect(@email.get("from_name")).toEqual @validEmail.from_name
      expect(@email.get("html_part")).toEqual @validEmail.html_part
      expect(@email.get("list_id")).toEqual @validEmail.list_id
      expect(@email.get("message_id")).toEqual @validEmail.message_id
      expect(@email.get("reply_to_address")).toEqual @validEmail.reply_to_address
      expect(@email.get("reply_to_name")).toEqual @validEmail.reply_to_name
      expect(@email.get("seen")).toEqual @validEmail.seen
      expect(@email.get("sender_address")).toEqual @validEmail.sender_address
      expect(@email.get("sender_name")).toEqual @validEmail.sender_name
      expect(@email.get("snippet")).toEqual @validEmail.snippet
      expect(@email.get("subject")).toEqual @validEmail.subject
      expect(@email.get("text_part")).toEqual @validEmail.text_part
      expect(@email.get("tos")).toEqual @validEmail.tos
      expect(@email.get("uid")).toEqual @validEmail.uid
      return

    it "should have the attributes", ->
      @email.fetch()
      @server.respond()
      
      expect(@email.get("auto_filed")).toBeDefined()
      expect(@email.get("bccs")).toBeDefined()
      expect(@email.get("body_text")).toBeDefined()
      expect(@email.get("ccs")).toBeDefined()
      expect(@email.get("date")).toBeDefined()
      expect(@email.get("from_address")).toBeDefined()
      expect(@email.get("from_name")).toBeDefined()
      expect(@email.get("html_part")).toBeDefined()
      expect(@email.get("list_id")).toBeDefined()
      expect(@email.get("message_id")).toBeDefined()
      expect(@email.get("reply_to_address")).toBeDefined()
      expect(@email.get("reply_to_name")).toBeDefined()
      expect(@email.get("seen")).toBeDefined()
      expect(@email.get("sender_address")).toBeDefined()
      expect(@email.get("sender_name")).toBeDefined()
      expect(@email.get("snippet")).toBeDefined()
      expect(@email.get("subject")).toBeDefined()
      expect(@email.get("text_part")).toBeDefined()
      expect(@email.get("tos")).toBeDefined()
      expect(@email.get("uid")).toBeDefined()
      return

    describe "when setSeen is called", ->

      it "updates the seen property", ->
        @email.fetch()
        @server.respond()
        expect(@email.get("seen")).toBeFalsy();
        @email.setSeen()
        expect(@email.get("seen")).toBeTruthy();
