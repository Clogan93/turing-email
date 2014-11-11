describe "DelayedEmailsRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @delayedEmailsRouter = new TuringEmailApp.Routers.DelayedEmailsRouter()

  afterEach ->
    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@delayedEmailsRouter.routes["delayed_emails"]).toEqual "showDelayedEmails"

  describe "delayed_emails", ->
    beforeEach ->
      @showDelayedEmailsStub = sinon.stub(TuringEmailApp, "showDelayedEmails")
      @delayedEmailsRouter.navigate "delayed_emails", trigger: true

    afterEach ->
      @showDelayedEmailsStub.restore()

    it "shows the delayed emails", ->
      expect(@showDelayedEmailsStub).toHaveBeenCalled()
