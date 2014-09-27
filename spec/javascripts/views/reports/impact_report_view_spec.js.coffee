describe "ImpactReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @impactReport = new TuringEmailApp.Models.ImpactReport()

    @impactReportDiv = $("<div />", {id: "impact_report"}).appendTo('body')
    @impactReportView = new TuringEmailApp.Views.Reports.ImpactReportView(
      model: @impactReport
      el: @impactReportDiv
    )

    impactReportFixtures = fixture.load("reports/impact_report.fixture.json", true);
    @impactReportFixture = impactReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.ImpactReport().url, JSON.stringify(@impactReportFixture)

  afterEach ->
    @server.restore()
    $(@impactReportDiv).remove()

  it "has the right template", ->
    expect(@impactReportView.template).toEqual JST["backbone/templates/reports/impact_report"]

  describe "#render", ->
    beforeEach ->
      @impactReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@impactReportDiv).toBeVisible()
      expect(@impactReportDiv).toContainHtml("Reports <small>impact</small>")
      
      expect(@impactReportDiv).toContainText("Percent of sent emails replied to:")
