describe "AnalyticsView", ->

  beforeEach ->
    @analyticsView = new TuringEmailApp.Views.AnalyticsView()

  it "should be defined", ->
    expect(TuringEmailApp.Views.AnalyticsView).toBeDefined()

  it "loads the list item template", ->
    expect(@analyticsView.template).toEqual JST["backbone/templates/analytics"]
