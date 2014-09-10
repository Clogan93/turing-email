describe "Word Count Report View", ->

  beforeEach ->
    @wordCountReport = new TuringEmailApp.Models.WordCountReport()
    @wordCountReportView = new TuringEmailApp.Views.Reports.WordCountReportView(
      model: @wordCountReport
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.WordCountReportView).toBeDefined()

  it "should have the right model", ->
    expect(@wordCountReportView.model).toEqual @wordCountReport

  it "loads the wordCountReport template", ->
    expect(@wordCountReportView.template).toEqual JST["backbone/templates/reports/word_count_report"]
