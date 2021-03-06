describe "FoldersReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @foldersReport = new TuringEmailApp.Models.Reports.FoldersReport()

    @foldersReportView = new TuringEmailApp.Views.Reports.FoldersReportView(
      model: @foldersReport
    )

    foldersReportFixtures = fixture.load("reports/folders_report.fixture.json", true);
    @foldersReportFixture = foldersReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.Reports.FoldersReport().url, JSON.stringify(@foldersReportFixture)

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@foldersReportView.template).toEqual JST["backbone/templates/reports/folders_report"]

  describe "#render", ->
    beforeEach ->
      @foldersReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@foldersReportView.$el).toContainHtml("Folders")

    folderNames = ["draft", "inbox", "sent", "spam", "starred", "trash", "unread"]
    for folderName in folderNames
      it "renders the percent of emails that are in the " + folderName + " folder", ->
        expect(@foldersReportView.$el).toContainHtml("<h4 class='h4'>Percent in the " + folderName + " folder: <small>" +
                                               @foldersReport.get("percent_" + folderName) * 100 +
                                               "%</small></h4>")
