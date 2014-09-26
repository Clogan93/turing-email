describe "ContactsReport", ->
  beforeEach ->
    contactsReportFixtures = fixture.load("reports/contacts_report.fixture.json", true);
    @contactsReportFixture = contactsReportFixtures[0]

    @contactsReport = new TuringEmailApp.Models.ContactsReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/contacts_report"
    @server.respondWith "GET", @url, JSON.stringify(@contactsReportFixture)

  afterEach ->
    @server.restore()

  it "should have the right url", ->
    expect(@contactsReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @contactsReport.fetch()
      @server.respond()

    it "loads the contacts report", ->
      validateAttributes(@contactsReport.toJSON(), ["top_senders", "top_recipients",
                                                    "bottom_senders", "bottom_recipients"])
