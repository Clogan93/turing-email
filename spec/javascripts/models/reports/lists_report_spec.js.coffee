describe "Lists report model", ->

  beforeEach ->
    @lists_report = new TuringEmailApp.Models.ListsReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.ListsReport).toBeDefined()

  it "should have the right url", ->
    expect(@lists_report.url).toEqual '/api/v1/email_reports/lists_report'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("reports/lists_report.fixture.json", true);

      @listsReport = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email_reports/lists_report", JSON.stringify(@listsReport)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @lists_report.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/email_reports/lists_report"
      return

    it "should parse the attributes from the response", ->
      @lists_report.fetch()
      @server.respond()

      expect(@lists_report.get("lists_email_daily_average")).toEqual @listsReport.lists_email_daily_average
      expect(@lists_report.get("emails_per_list")).toEqual @listsReport.emails_per_list
      expect(@lists_report.get("email_threads_per_list")).toEqual @listsReport.email_threads_per_list
      expect(@lists_report.get("email_threads_replied_to_per_list")).toEqual @listsReport.email_threads_replied_to_per_list
      expect(@lists_report.get("sent_emails_per_list")).toEqual @listsReport.sent_emails_per_list
      expect(@lists_report.get("sent_emails_replied_to_per_list")).toEqual @listsReport.sent_emails_replied_to_per_list
      return

    it "should have the attributes", ->
      @lists_report.fetch()
      @server.respond()

      expect(@lists_report.get("lists_email_daily_average")).toBeDefined()
      expect(@lists_report.get("emails_per_list")).toBeDefined()
      expect(@lists_report.get("email_threads_per_list")).toBeDefined()
      expect(@lists_report.get("email_threads_replied_to_per_list")).toBeDefined()
      expect(@lists_report.get("sent_emails_per_list")).toBeDefined()
      expect(@lists_report.get("sent_emails_replied_to_per_list")).toBeDefined()
      return
