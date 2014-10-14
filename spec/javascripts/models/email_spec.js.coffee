describe "Email", ->
  describe "#sendEmail", ->
    beforeEach ->
      @sendEmailURL = "/api/v1/email_accounts/send_email"
  
      emailFixtures = fixture.load("email.fixture.json", true)
      @validEmailFixtures = emailFixtures[0]["valid"]

      @server = sinon.fakeServer.create()
      @server.respondWith "POST", @sendEmailURL, JSON.stringify({})

      @email = new TuringEmailApp.Models.Email()
      @email.tos = ["test@turinginc.com"]
      
      @email.sendEmail()
      @server.respond()

    afterEach ->
      @server.restore()
      
    it "should send the email", ->
      expect(@server.requests.length).toEqual 1
      request = @server.requests[0]
      expect(request.method).toEqual "POST"
      expect(request.url).toEqual @sendEmailURL

    describe "Class Methods", ->

      describe "#localDateString", ->

        describe "when the date is within the last 18 hours", ->

          it "produces the a time format response", ->
            date = new Date(Date.now())
            isoDateString = date.toISOString()
            expect(TuringEmailApp.Models.Email.localDateString(isoDateString)).toEqual date.toLocaleTimeString(navigator.language, {hour: "2-digit", minute: "2-digit"})

        describe "when the date is further back than 18 hours ago", ->

          it "produces a date format response", ->
            expect(TuringEmailApp.Models.Email.localDateString("2014-08-22T17:28:16.000Z")).toEqual "Aug 22"

        describe "when the emailDateString is not defined", ->

          it "return an empty string", ->
            expect(TuringEmailApp.Models.Email.localDateString(null)).toEqual ""

    describe "Instance Methods", ->
      beforeEach ->
        emailUrl = "/api/v1/emails/email"
        @email.url = emailUrl
        @server.respondWith "GET", emailUrl, JSON.stringify(@validEmailFixtures)
        @email.fetch()
        @server.respond()

      describe "#localDateString", ->

        it "calls the localDateString class method", ->
          spy = sinon.spy(TuringEmailApp.Models.Email, "localDateString")
          @email.localDateString()
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith "2014-08-22T17:28:16.000Z"
          spy.restore()
