describe "AttachmentsReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @attachmentsReport = new TuringEmailApp.Models.Reports.AttachmentsReport()

    @attachmentsReportView = new TuringEmailApp.Views.Reports.AttachmentsReportView(
      model: @attachmentsReport
    )

    attachmentsReportFixtures = fixture.load("reports/attachments_report.fixture.json", true);
    @attachmentsReportFixture = attachmentsReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.Reports.AttachmentsReport().url, JSON.stringify(@attachmentsReportFixture)

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@attachmentsReportView.template).toEqual JST["backbone/templates/reports/attachments_report"]

  describe "#render", ->
    beforeEach ->
      @attachmentsReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@attachmentsReportView.$el).toContainHtml("Attachments")

      divSelectors = [".num_attachments_chart_div", ".average_file_size_chart_div"]

      for divSelector in divSelectors
        div = @attachmentsReportView.$el.find(divSelector)
        expect(div.length).toEqual(1)

    it "renders the google chart", ->
      spy = sinon.spy(@attachmentsReportView, "renderGoogleChart")
      @attachmentsReportView.render()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe "#getGoogleChartData", ->
    beforeEach ->
      @attachmentsReport.fetch()
      @server.respond()
      
      @expectedGoogleChartData = JSON.parse('{"averageFileSize":200280,"numAttachmentsGChartData":[["Attachment Type","Number of Attachments"],["Document",2],["Image",14],["PDF",2]],"averageFileSizeGChartData":[["Attachment Type","Average File Size"],["Document",1068192],["Image",24711],["PDF",561352]]}')

    it "converts the model into Google Chart data format", ->
      expect(@attachmentsReportView.getGoogleChartData()).toEqual(@expectedGoogleChartData)

  describe "#addContentTypeStatsToRunningAverage", ->
    # TODO write tests
      
  describe "#getReducedContentTypeStats", ->
    beforeEach ->
      @contentTypeStats = 
        "image/jpg": {num_attachments: 1, average_file_size: 5}
        "image/png": {num_attachments: 2, average_file_size: 10}
        "application/pdf": {num_attachments: 3, average_file_size: 13}
        "application-x/pdf": {num_attachments: 10, average_file_size: 7}
        "application/octet-stream": {num_attachments: 4, average_file_size: 7}

      @reducedContentTypeStats = @attachmentsReportView.getReducedContentTypeStats(@contentTypeStats)

    it "reduces the contentTypeStats", ->
      expect(@reducedContentTypeStats.Image.numAttachments).toEqual(3)
      expect(@reducedContentTypeStats.Image.averageFileSize).toEqual(25 / 3)

      expect(@reducedContentTypeStats.PDF.numAttachments).toEqual(13)
      expect(@reducedContentTypeStats.PDF.averageFileSize).toEqual((3*13+10*7) / 13)

      expect(@reducedContentTypeStats.Other.numAttachments).toEqual(4)
      expect(@reducedContentTypeStats.Other.averageFileSize).toEqual(7)

  describe "#renderGoogleChart", ->
    beforeEach ->
      @attachmentsReport.fetch()
      @server.respond()
      
      @expectedGoogleChartData = JSON.parse('{"averageFileSize":200280,"numAttachmentsGChartData":[["Attachment Type","Number of Attachments"],["Document",2],["Image",14],["PDF",2]],"averageFileSizeGChartData":[["Attachment Type","Average File Size"],["Document",1068192],["Image",24711],["PDF",561352]]}')
