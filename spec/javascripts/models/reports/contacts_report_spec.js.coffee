describe "Contacts report model", ->

  beforeEach ->
    @contacts_report = new TuringEmailApp.Models.ContactsReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.ContactsReport).toBeDefined()

  it "should have the right url", ->
    expect(@contacts_report.url).toEqual '/api/v1/emails/contacts_report'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("reports/contacts_report.fixture.json", true);

      @contactsReport = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/emails/contacts_report", JSON.stringify(@contactsReport)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @contacts_report.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/emails/contacts_report"
      return

    it "should parse the attributes from the response", ->
      @contacts_report.fetch()
      @server.respond()

      expect(@contacts_report.get("top_senders")).toEqual @contactsReport.top_senders
      expect(@contacts_report.get("top_recipients")).toEqual @contactsReport.top_recipients
      expect(@contacts_report.get("bottom_senders")).toEqual @contactsReport.bottom_senders
      expect(@contacts_report.get("bottom_recipients")).toEqual @contactsReport.bottom_recipients
      return

    it "should have the attributes", ->
      @contacts_report.fetch()
      @server.respond()

      expect(@contacts_report.get("top_senders")).toBeDefined()
      expect(@contacts_report.get("top_recipients")).toBeDefined()
      expect(@contacts_report.get("bottom_senders")).toBeDefined()
      expect(@contacts_report.get("bottom_recipients")).toBeDefined()
      return
