describe "Contacts report model", ->

  beforeEach ->
    @contacts_report = new TuringEmailApp.Models.ContactsReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.ContactsReport).toBeDefined()

  it "should have the right url", ->
    expect(@contacts_report.url).toEqual '/api/v1/email_reports/contacts_report'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("reports/contacts_report.fixture.json", true);

      @contactsReport = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email_reports/contacts_report", JSON.stringify(@contactsReport)

      @contactsReport = @contacts_report.parse @contactsReport
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @contacts_report.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/email_reports/contacts_report"
      return

    it "should parse the attributes from the response", ->
      @contacts_report.fetch()
      @server.respond()

      expect(@contacts_report.get("incomingEmailData")).toEqual @contactsReport.incomingEmailData
      expect(@contacts_report.get("outgoingEmailData")).toEqual @contactsReport.outgoingEmailData
      return

    it "should have the attributes", ->
      @contacts_report.fetch()
      @server.respond()

      expect(@contacts_report.get("incomingEmailData")).toBeDefined()
      expect(@contacts_report.get("outgoingEmailData")).toBeDefined()
      return
