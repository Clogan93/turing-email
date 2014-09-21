describe "AnalyticsRouter", ->

  beforeEach ->
    @router = new TuringEmailApp.Routers.AnalyticsRouter()
    TuringEmailApp.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
    @routeSpy = sinon.spy()
    try
      Backbone.history.start
        silent: true

  it "has a analytics route and points to the showAnalytics method", ->
    expect(@router.routes["analytics"]).toEqual "showAnalytics"

  it "fires the showAnalytics route with analytics", ->
    @router.bind "route:showAnalytics", @routeSpy
    @router.navigate "analytics",
      trigger: true
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith()
    return
