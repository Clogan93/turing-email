describe "AnalyticsRouter", ->
  specStartTuringEmailApp()
  
  beforeEach ->
    @emailFoldersRouter = new TuringEmailApp.Routers.AnalyticsRouter()

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  it "has the expected routes", ->
    expect(@emailFoldersRouter.routes["analytics"]).toEqual "showAnalytics"

  describe "analytics", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views, "AnalyticsView")
      @emailFoldersRouter.navigate "analytics", trigger: true
    
    it "shows an AnalyticsView", ->
      expect(@spy.called).toBeTruthy()
