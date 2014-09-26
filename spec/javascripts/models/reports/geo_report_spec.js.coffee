describe "GeoReport", ->
  beforeEach ->
    geoReportFixtures = fixture.load("reports/geo_report.fixture.json", true);
    @validGeoReportFixture = geoReportFixtures[0]

    @geoReport = new TuringEmailApp.Models.GeoReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/ip_stats_report"
    @server.respondWith "GET", @url, JSON.stringify(@validGeoReportFixture)

  afterEach ->
    @server.restore()

  it "should have the right url", ->
    expect(@geoReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @geoReport.fetch()
      @server.respond()

    it "loads the contacts report", ->
      validateAttributes(@geoReport.toJSON(), ["ip_stats"])
