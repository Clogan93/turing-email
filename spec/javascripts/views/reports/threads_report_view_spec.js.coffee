describe "Threads Report View", ->

  beforeEach ->
    @threadsReport = new TuringEmailApp.Models.ThreadsReport()
    @threadsReportView = new TuringEmailApp.Views.Reports.ThreadsReportView(
      model: @threadsReport
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.ThreadsReportView).toBeDefined()

  it "should have the right model", ->
    expect(@threadsReportView.model).toEqual @threadsReport

  it "loads the threadsReport template", ->
    expect(@threadsReportView.template).toEqual JST["backbone/templates/reports/threads_report"]
