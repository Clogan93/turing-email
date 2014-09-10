describe "Impact report model", ->

  beforeEach ->
    @impact_report = new TuringEmailApp.Models.ImpactReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.ImpactReport).toBeDefined()

  it "should have the right url", ->
    expect(@impact_report.url).toEqual '/api/v1/emails/impact_report'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("reports/impact_report.fixture.json", true);

      @impactReport = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/emails/impact_report", JSON.stringify(@impactReport)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @impact_report.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/emails/impact_report"
      return

    it "should parse the attributes from the response", ->
      @impact_report.fetch()
      @server.respond()

      expect(@impact_report.get("percent_sent_emails_replied_to")).toEqual @impactReport.percent_sent_emails_replied_to
      return

    it "should have the attributes", ->
      @impact_report.fetch()
      @server.respond()

      expect(@impact_report.get("percent_sent_emails_replied_to")).toEqual @impactReport.percent_sent_emails_replied_to
      expect(@impact_report.get("percent_sent_emails_replied_to")).toBeDefined()
      return
