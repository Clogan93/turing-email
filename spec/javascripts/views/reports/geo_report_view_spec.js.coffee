describe "Geo Report View", ->

  beforeEach ->
    @geoReport = new TuringEmailApp.Models.GeoReport()
    @geoReportView = new TuringEmailApp.Views.Reports.GeoReportView(
      model: @geoReport
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.GeoReportView).toBeDefined()

  it "should have the right model", ->
    expect(@geoReportView.model).toEqual @geoReport

  it "loads the geoReport template", ->
    expect(@geoReportView.template).toEqual JST["backbone/templates/reports/geo_report"]
