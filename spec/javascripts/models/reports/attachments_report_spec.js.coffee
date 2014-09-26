describe "AttachmentsReport", ->
  beforeEach ->
    attachmentsReportFixtures = fixture.load("reports/attachments_report.fixture.json", true);
    @validAttachmentsReportFixture = attachmentsReportFixtures[0]

    @attachmentsReport = new TuringEmailApp.Models.AttachmentsReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/attachments_report"
    @server.respondWith "GET", @url, JSON.stringify(@validAttachmentsReportFixture)

  afterEach ->
    @server.restore()

  it "should have the right url", ->
    expect(@attachmentsReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @attachmentsReport.fetch()
      @server.respond()

    it "loads the attachments report", ->
      validateAttributes(@attachmentsReport.toJSON(), ["average_file_size", "content_type_stats"])
