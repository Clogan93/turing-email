describe "Email", ->
  describe "#sendEmail", ->
    beforeEach ->
      @sendEmailURL = "/api/v1/email_accounts/send_email"
  
      @server = sinon.fakeServer.create()
      @server.respondWith "POST", @sendEmailURL, JSON.stringify({})

      email = new TuringEmailApp.Models.Email()
      email.tos = ["test@turinginc.com"]
      
      email.sendEmail()
      @server.respond()

    afterEach ->
      @server.restore()
      
    it "should send the email", ->
      expect(@server.requests.length).toEqual 1
      request = @server.requests[0]
      expect(request.method).toEqual "POST"
      expect(request.url).toEqual @sendEmailURL
