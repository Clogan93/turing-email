describe "Email volume report model", ->

  beforeEach ->
    @email_volume_report = new TuringEmailApp.Models.EmailVolumeReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.EmailVolumeReport).toBeDefined()

  it "should have the right url", ->
    expect(@email_volume_report.url).toEqual '/api/v1/emails/volume_report'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("reports/email_volume_report.fixture.json", true);

      @emailVolumeReport = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/emails/volume_report", JSON.stringify(@emailVolumeReport)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @email_volume_report.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/emails/volume_report"
      return

    it "should parse the attributes from the response", ->
      @email_volume_report.fetch()
      @server.respond()

      expect(@email_volume_report.get("dailyEmailVolumeData")).toEqual @emailVolumeReport.dailyEmailVolumeData
      expect(@email_volume_report.get("weeklyEmailVolumeData")).toEqual @emailVolumeReport.weeklyEmailVolumeData
      expect(@email_volume_report.get("monthlyEmailVolumeData")).toEqual @emailVolumeReport.monthlyEmailVolumeData
      return

    it "should have the attributes", ->
      @email_volume_report.fetch()
      @server.respond()
      
      expect(@email_volume_report.get("dailyEmailVolumeData")).toBeDefined()
      expect(@email_volume_report.get("weeklyEmailVolumeData")).toBeDefined()
      expect(@email_volume_report.get("monthlyEmailVolumeData")).toBeDefined()
      return
