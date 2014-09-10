describe "Impact report model", ->

  beforeEach ->
    @impact_report = new TuringEmailApp.Models.ImpactReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.ImpactReport).toBeDefined()

  it "should have the right url", ->
    expect(@impact_report.url).toEqual '/api/v1/emails/impact_report'
