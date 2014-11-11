describe "DelayedEmail", ->
  describe "Class Functions", ->
    describe "#Delete", ->
      beforeEach ->
        @delayedEmailUID = "uid"
        @ajaxStub = sinon.stub($, "ajax", ->)
        
        TuringEmailApp.Models.DelayedEmail.Delete(@delayedEmailUID)

      afterEach ->
        @ajaxStub.restore()
        
      it "submits the DELETE", ->
        expect(@ajaxStub).toHaveBeenCalledWith(
          url: "/api/v1/delayed_emails/" + @delayedEmailUID
          type: "DELETE"
        )

  beforeEach ->
    @delayedEmail = new TuringEmailApp.Models.DelayedEmail()

  it "uses uid as idAttribute", ->
    expect(@delayedEmail.idAttribute).toEqual("uid")
