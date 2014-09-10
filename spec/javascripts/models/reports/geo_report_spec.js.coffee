describe "Geo report model", ->

  beforeEach ->
    @geo_report = new TuringEmailApp.Models.GeoReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.GeoReport).toBeDefined()

  it "should have the right url", ->
    expect(@geo_report.url).toEqual '/api/v1/emails/ip_stats'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("reports/geo_report.fixture.json", true);

      @geoReport = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/emails/ip_stats", JSON.stringify(@geoReport)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @geo_report.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/emails/ip_stats"
      return

    it "should parse the attributes from the response", ->
      @geo_report.fetch()
      @server.respond()

      for index, geoData of @geo_report.attributes
        expect(geoData.num_emails).toEqual geoData.num_emails
        expect(geoData.ip_info).toEqual geoData.ip_info
      return

    it "should have the attributes", ->
      @geo_report.fetch()
      @server.respond()

      for index, geoData of @geo_report.attributes
        expect(geoData.num_emails).toBeDefined()
        expect(geoData.ip_info).toBeDefined()
      return
