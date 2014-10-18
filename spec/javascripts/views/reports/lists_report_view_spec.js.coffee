describe "ListsReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @listsReport = new TuringEmailApp.Models.Reports.ListsReport()

    @listsReportView = new TuringEmailApp.Views.Reports.ListsReportView(
      model: @listsReport
    )

    listsReportFixtures = fixture.load("reports/lists_report.fixture.json", true);
    @listsReportFixture = listsReportFixtures[0]

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@listsReportView.template).toEqual JST["backbone/templates/reports/lists_report"]

  describe "#render", ->
    beforeEach ->
      @server.respondWith "GET", new TuringEmailApp.Models.Reports.ListsReport().url, JSON.stringify(@listsReportFixture)
      @listsReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@listsReportView.$el).toContainHtml("Lists")

      listReportStatsDiv = @listsReportView.$el.find("#list_report_statistics")
      expect(listReportStatsDiv).toContainHtml('<h4 class="h4">Lists email daily average</h4>')
      expect(listReportStatsDiv).toContainHtml('<h4 class="h4">Emails per list</h4>')
      expect(listReportStatsDiv).toContainHtml('<h4 class="h4">Email threads per list</h4>')
      expect(listReportStatsDiv).toContainHtml('<h4 class="h4">Email threads replied to per list</h4>')
      expect(listReportStatsDiv).toContainHtml('<h4 class="h4">Sent emails per list</h4>')
      expect(listReportStatsDiv).toContainHtml('<h4 class="h4">Sent emails replied to per list</h4>')

  describe "when the first item in the list stats is null", ->
    beforeEach ->
      @server.respondWith "GET", new TuringEmailApp.Models.Reports.ListsReport().url, JSON.stringify(@listsReportFixture)
      @listsReport.fetch()
      @server.respond()

    it "renders the second list stat", ->
      # TODO figure out how to test the second list stat.
