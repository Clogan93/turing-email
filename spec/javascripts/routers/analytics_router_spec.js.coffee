describe "AnalyticsRouter", ->
  specStartTuringEmailApp()
  
  beforeEach ->
    @analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()

    @server = sinon.fakeServer.create()

  it "has the expected routes", ->
    expect(@analyticsRouter.routes["analytics"]).toEqual "showAnalytics"

  describe "#analytics", ->
    beforeEach ->
      $("<div/>", {id: "reports"}).appendTo($("body"))
      @analyticsRouter.navigate "#analytics", trigger: true
    
    it "shows an AnalyticsView", ->
      console.log $("#contacts_report")
      expect(true).toBeTruthy()
