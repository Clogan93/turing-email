describe "AnalyticsRouter", ->
  specStartTuringEmailApp()
  
  beforeEach ->
    @analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()

  it "has the expected routes", ->
    expect(@analyticsRouter.routes["analytics"]).toEqual "showAnalytics"

  describe "#analytics", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "showAnalytics")
      try
        @analyticsRouter.navigate "#analytics", trigger: true
    
    it "shows an AnalyticsView", ->
      expect(@spy).toHaveBeenCalledOnce()
