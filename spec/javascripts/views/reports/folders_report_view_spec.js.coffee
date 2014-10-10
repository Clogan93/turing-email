describe "FoldersReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @foldersReport = new TuringEmailApp.Models.FoldersReport()

    @foldersReportDiv = $("<div />", {id: "folders_report"}).appendTo("body")
    @foldersReportView = new TuringEmailApp.Views.Reports.FoldersReportView(
      model: @foldersReport
      el: @foldersReportDiv
    )

    foldersReportFixtures = fixture.load("reports/folders_report.fixture.json", true);
    @foldersReportFixture = foldersReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.FoldersReport().url, JSON.stringify(@foldersReportFixture)

  afterEach ->
    @server.restore()
    @foldersReportDiv.remove()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@foldersReportView.template).toEqual JST["backbone/templates/reports/folders_report"]

  describe "#render", ->
    beforeEach ->
      @foldersReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@foldersReportDiv).toBeVisible()
      expect(@foldersReportDiv).toContainHtml("Reports <small>folders</small>")

    folderNames = ["draft", "inbox", "sent", "spam", "starred", "trash", "unread"]
    for folderName in folderNames
      it "renders the percent of emails that are in the " + folderName + " folder", ->
        expect(@foldersReportDiv).toContainHtml("<h4 class='h4'>Percent in the " + folderName + " folder: <small>" +
                                               @foldersReport.get("percent_" + folderName) * 100 +
                                               "%</small></h4>")
