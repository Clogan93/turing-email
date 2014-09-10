describe "Geo report model", ->

  beforeEach ->
    @geo_report = new TuringEmailApp.Models.GeoReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.GeoReport).toBeDefined()

  it "should have the right url", ->
    expect(@geo_report.url).toEqual '/api/v1/emails/ip_stats'
