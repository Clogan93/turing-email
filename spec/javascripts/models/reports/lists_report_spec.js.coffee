describe "Lists report model", ->

  beforeEach ->
    @lists_report = new TuringEmailApp.Models.ListsReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.ListsReport).toBeDefined()

  it "should have the right url", ->
    expect(@lists_report.url).toEqual '/api/v1/emails/lists_report'
