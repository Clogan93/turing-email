describe "Top senders and recipients report model", ->

  beforeEach ->
    @top_senders_and_recipients_report = new TuringEmailApp.Models.TopSendersAndRecipientsReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.TopSendersAndRecipientsReport).toBeDefined()

  it "should have the right url", ->
    expect(@top_senders_and_recipients_report.url).toEqual '/api/v1/emails/contacts_report'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("reports/top_senders_and_recipients_report.fixture.json", true);

      @threadsReport = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/emails/contacts_report", JSON.stringify(@threadsReport)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @top_senders_and_recipients_report.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/emails/contacts_report"
      return

    it "should parse the attributes from the response", ->
      @top_senders_and_recipients_report.fetch()
      @server.respond()

      expect(@top_senders_and_recipients_report.get("top_senders")).toEqual @threadsReport.top_senders
      expect(@top_senders_and_recipients_report.get("top_recipients")).toEqual @threadsReport.top_recipients
      expect(@top_senders_and_recipients_report.get("bottom_senders")).toEqual @threadsReport.bottom_senders
      expect(@top_senders_and_recipients_report.get("bottom_recipients")).toEqual @threadsReport.bottom_recipients
      return

    it "should have the attributes", ->
      @top_senders_and_recipients_report.fetch()
      @server.respond()

      expect(@top_senders_and_recipients_report.get("top_senders")).toBeDefined()
      expect(@top_senders_and_recipients_report.get("top_recipients")).toBeDefined()
      expect(@top_senders_and_recipients_report.get("bottom_senders")).toBeDefined()
      expect(@top_senders_and_recipients_report.get("bottom_recipients")).toBeDefined()
      return
