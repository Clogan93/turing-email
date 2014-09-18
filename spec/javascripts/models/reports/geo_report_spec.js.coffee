describe "Geo report model", ->

  beforeEach ->
    @geo_report = new TuringEmailApp.Models.GeoReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.GeoReport).toBeDefined()

  it "should have the right url", ->
    expect(@geo_report.url).toEqual '/api/v1/email_reports/ip_stats'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("reports/geo_report.fixture.json", true);

      @geoReport = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email_reports/ip_stats", JSON.stringify(@geoReport)

      @geoReport = @geo_report.parse @geoReport
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @geo_report.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/email_reports/ip_stats"
      return

    it "should parse the attributes from the response", ->
      @geo_report.fetch()
      @server.respond()

      expect(@geo_report.get("data")).toEqual @geoReport.data
      return

    it "should have the attributes", ->
      @geo_report.fetch()
      @server.respond()

      expect(@geo_report.get("data")).toBeDefined()
      return
