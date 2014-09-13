describe "Lists Report View", ->

  beforeEach ->
    @listsReport = new TuringEmailApp.Models.ListsReport()
    @listsReportView = new TuringEmailApp.Views.Reports.ListsReportView(
      model: @listsReport
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.ListsReportView).toBeDefined()

  it "should have the right model", ->
    expect(@listsReportView.model).toEqual @listsReport

  it "loads the listsReport template", ->
    expect(@listsReportView.template).toEqual JST["backbone/templates/reports/lists_report"]
