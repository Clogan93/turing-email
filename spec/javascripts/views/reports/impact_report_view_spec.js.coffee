describe "Impact Report View", ->

  beforeEach ->
    @impactReport = new TuringEmailApp.Models.ImpactReport()
    @impactReportView = new TuringEmailApp.Views.Reports.ImpactReportView(
      model: @impactReport
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.ImpactReportView).toBeDefined()

  it "should have the right model", ->
    expect(@impactReportView.model).toEqual @impactReport

  it "loads the impactReport template", ->
    expect(@impactReportView.template).toEqual JST["backbone/templates/reports/impact_report"]
