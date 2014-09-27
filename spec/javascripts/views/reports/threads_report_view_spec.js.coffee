describe "ThreadsReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @threadsReport = new TuringEmailApp.Models.ThreadsReport()

    @threadsReportDiv = $("<div />", {id: "threads_report"}).appendTo('body')
    @threadsReportView = new TuringEmailApp.Views.Reports.ThreadsReportView(
      model: @threadsReport
      el: @threadsReportDiv
    )

    threadsReportFixtures = fixture.load("reports/threads_report.fixture.json", true);
    @threadsReportFixture = threadsReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.ThreadsReport().url, JSON.stringify(@threadsReportFixture)

  afterEach ->
    @server.restore()
    $(@threadsReportDiv).remove()

  it "has the right template", ->
    expect(@threadsReportView.template).toEqual JST["backbone/templates/reports/threads_report"]

  describe "#render", ->
    beforeEach ->
      @threadsReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@threadsReportDiv).toBeVisible()
      expect(@threadsReportDiv).toContainHtml("Reports <small>threads</small>")
      
      expect(@threadsReportDiv).toContainText("Average Thread Length:")
      expect(@threadsReportDiv).toContainHtml('<h4 class="h4">Top Email Threads</h4>')
