describe "Threads report model", ->

  beforeEach ->
    @threads_report = new TuringEmailApp.Models.ThreadsReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.ThreadsReport).toBeDefined()

  it "should have the right url", ->
    expect(@threads_report.url).toEqual '/api/v1/emails/threads_report'
