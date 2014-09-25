describe "AnalyticsRouter", ->
  specStartTuringEmailApp()
  
  beforeEach ->
    @analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  it "has the expected routes", ->
    expect(@analyticsRouter.routes["analytics"]).toEqual "showAnalytics"

  describe "analytics", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views, "AnalyticsView")
      @analyticsRouter.navigate "analytics", trigger: true
    
    it "shows an AnalyticsView", ->
      expect(@spy.called).toBeTruthy()
