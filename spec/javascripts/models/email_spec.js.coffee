describe "Email", ->
  beforeEach ->
    @sendEmailURL = "/api/v1/email_accounts/send_email"

    @email = new TuringEmailApp.Models.Email()

    @server = sinon.fakeServer.create()
    @server.respondWith "POST", @sendEmailURL, JSON.stringify({})

  afterEach ->
    @server.restore()

  describe "#sendEmail", ->
    beforeEach ->
      @email.tos = ["test@turinginc.com"]

      @email.sendEmail()
      @server.respond()

    it "should send the email", ->
      expect(@server.requests.length).toEqual 1
      request = @server.requests[0]
      expect(request.method).toEqual "POST"
      expect(request.url).toEqual @sendEmailURL
