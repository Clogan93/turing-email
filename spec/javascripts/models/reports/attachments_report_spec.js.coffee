describe "Attachments report model", ->

  beforeEach ->
    @attachments_report = new TuringEmailApp.Models.AttachmentsReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.AttachmentsReport).toBeDefined()

  it "should have the right url", ->
    expect(@attachments_report.url).toEqual '/api/v1/emails/attachments_report'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("reports/attachments_report.fixture.json", true);

      @attachmentReport = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/emails/attachments_report", JSON.stringify(@attachmentReport)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @attachments_report.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/emails/attachments_report"
      return

    it "should parse the attributes from the response", ->
      @attachments_report.fetch()
      @server.respond()
      console.log @attachments_report

      expect(@attachments_report.get("average_file_size")).toEqual @attachmentReport.average_file_size
      expect(@attachments_report.get("content_type_stats")).toEqual @attachmentReport.content_type_stats
      return

    it "should have the attributes", ->
      @attachments_report.fetch()
      @server.respond()
      
      expect(@attachments_report.get("average_file_size")).toBeDefined()
      expect(@attachments_report.get("content_type_stats")).toBeDefined()
      return
