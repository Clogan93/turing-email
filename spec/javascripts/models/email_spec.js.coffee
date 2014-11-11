describe "Email", ->
  describe "Class Methods", ->
    describe "#localDateString", ->
      describe "when the date is within the last 18 hours", ->
        it "produces the a time format response", ->
          date = new Date(Date.now())
          isoDateString = date.toISOString()
          expectedResult = date.toLocaleTimeString(navigator.language, {hour: "2-digit", minute: "2-digit"})
          expect(TuringEmailApp.Models.Email.localDateString(isoDateString)).toEqual(expectedResult)

      describe "when the date is further back than 18 hours ago", ->
        it "produces a date format response", ->
          expect(TuringEmailApp.Models.Email.localDateString("2014-08-22T17:28:16.000Z")).toEqual "Aug 22"

      describe "when the emailDateString is not defined", ->
        it "return an empty string", ->
          expect(TuringEmailApp.Models.Email.localDateString(null)).toEqual ""

  describe "Instance Methods", ->
    describe "#sendEmail", ->
      beforeEach ->
        @sendEmailURL = "/api/v1/email_accounts/send_email"
        @postStub = sinon.stub($, "post", ->)
  
        @email = new TuringEmailApp.Models.Email()
        @email.tos = ["test@turinginc.com"]
  
        @email.sendEmail()
  
      afterEach ->
        @postStub.restore()
  
      it "sends the email", ->
        expect(@postStub).toHaveBeenCalledWith(@sendEmailURL, @email.toJSON(), undefined, "json")

    describe "#sendLater", ->
      beforeEach ->
        @sendEmailURL = "/api/v1/email_accounts/send_email_delayed"
        @postStub = sinon.stub($, "post", ->)

        @date = new Date().toString()
        @email = new TuringEmailApp.Models.Email()
        @email.tos = ["test@turinginc.com"]

        @data = @email.toJSON()
        @data["sendAtDateTime"] = @date

        @email.sendLater(@date)

      afterEach ->
        @postStub.restore()

      it "sends the email", ->
        expect(@postStub).toHaveBeenCalledWith(@sendEmailURL, @data, undefined, "json")
        
    describe "#localDateString", ->
      beforeEach ->
        @localDateStringSpy = sinon.spy(TuringEmailApp.Models.Email, "localDateString")

        @email = new TuringEmailApp.Models.Email(FactoryGirl.create("Email"))
        @email.localDateString()

      afterEach ->
        @localDateStringSpy.restore()
        
      it "calls the localDateString class method", ->
        expect(@localDateStringSpy).toHaveBeenCalledWith(@email.get("date"))
