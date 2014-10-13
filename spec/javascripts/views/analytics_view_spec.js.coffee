describe "AnalyticsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @analyticsView = new TuringEmailApp.Views.AnalyticsView()
    @server = specPrepareReportFetches() 

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()
    
  it "has the right template", ->
    expect(@analyticsView.template).toEqual JST["backbone/templates/analytics"]

  describe "#render", ->
    beforeEach ->
      @analyticsView.render()
      @server.respond()
    
    it "renders the reports", ->
      verifyReportsRendered(@analyticsView.$el)
