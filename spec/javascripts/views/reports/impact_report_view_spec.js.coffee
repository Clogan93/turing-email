describe "Impact Report View", ->

  beforeEach ->
    @impactReport = new TuringEmailApp.Models.ImpactReport()
    @impactReportView = null
    TuringEmailApp.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()

  describe "when render is called", ->

    beforeEach ->
      @fixtures = fixture.load("reports/impact_report.fixture.json", true)

      @impactReportFixture = @fixtures[0]

      @server = sinon.fakeServer.create()

      @server.respondWith "GET", "/api/v1/emails/impact_report", JSON.stringify(@impactReportFixture)

      @impactReportView = new TuringEmailApp.Views.Reports.ImpactReportView(
        model: @impactReport
      )
      
      @impactReportView.fetch()

      @server.respond()

    afterEach ->
      @server.restore()

    it "should have the root element be a div", ->
      expect(@impactReportView.el.nodeName).toEqual "DIV"

    it "should be defined", ->
      expect(TuringEmailApp.Views.Reports.ImpactReportView).toBeDefined()

    it "should have the right model", ->
      expect(@impactReportView.model).toEqual @impactReport

    it "loads the impactReport template", ->
      expect(@impactReportView.template).toEqual JST["backbone/templates/reports/impact_report"]

    it "should show the percent of sent emails replied to", ->
      expect(@impactReportView.$el.find("h4 small").text()).toEqual (@impactReport.get("percent_sent_emails_replied_to").toString() + "%")
