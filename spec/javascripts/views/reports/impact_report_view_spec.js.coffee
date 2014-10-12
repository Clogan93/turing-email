describe "ImpactReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @impactReport = new TuringEmailApp.Models.Reports.ImpactReport()

    @impactReportDiv = $("<div />", {id: "impact_report"}).appendTo("body")
    @impactReportView = new TuringEmailApp.Views.Reports.ImpactReportView(
      model: @impactReport
      el: @impactReportDiv
    )

    impactReportFixtures = fixture.load("reports/impact_report.fixture.json", true);
    @impactReportFixture = impactReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.Reports.ImpactReport().url, JSON.stringify(@impactReportFixture)

  afterEach ->
    @server.restore()
    @impactReportDiv.remove()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@impactReportView.template).toEqual JST["backbone/templates/reports/impact_report"]

  describe "#render", ->
    beforeEach ->
      @impactReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@impactReportDiv).toBeVisible()
      expect(@impactReportDiv).toContainHtml("Reports <small>impact</small>")

    it "renders the percent of sent emails replied to", ->
      expect(@impactReportDiv).toContainHtml('<h4 class="h4">Percent of sent emails replied to: <small>' +
                                             @impactReport.get("percent_sent_emails_replied_to") * 100 +
                                             '%</small></h4>')
