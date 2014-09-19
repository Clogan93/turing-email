describe "AnalyticsRouter", ->

  beforeEach ->
    @router = new TuringEmailApp.Routers.AnalyticsRouter()
    @routeSpy = sinon.spy()
    try
      TuringEmailApp.start()

  it "has a analytics route and points to the showAnalytics method", ->
    expect(@router.routes["analytics"]).toEqual "showAnalytics"
