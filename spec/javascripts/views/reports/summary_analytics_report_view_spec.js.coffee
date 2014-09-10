describe "Summary Analytics Report View", ->

  beforeEach ->
    @summaryAnalyticsReport = new TuringEmailApp.Models.SummaryAnalyticsReport()
    @summaryAnalyticsReportView = new TuringEmailApp.Views.Reports.SummaryAnalyticsReportView(
      model: @summaryAnalyticsReport
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.SummaryAnalyticsReportView).toBeDefined()

  it "should have the right model", ->
    expect(@summaryAnalyticsReportView.model).toEqual @summaryAnalyticsReport

  it "loads the summaryAnalyticsReport template", ->
    expect(@summaryAnalyticsReportView.template).toEqual JST["backbone/templates/reports/summary_analytics_report"]
