describe "Threads Report View", ->

  beforeEach ->
    @threadsReport = new TuringEmailApp.Models.ThreadsReport()
    @threadsReportView = null
    TuringEmailApp.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()

  describe "when render is called", ->

    beforeEach ->
      @fixtures = fixture.load("reports/threads_report.fixture.json", true)

      @threadsReportFixture = @fixtures[0]

      @server = sinon.fakeServer.create()

      @server.respondWith "GET", "/api/v1/email_reports/threads_report", JSON.stringify(@threadsReportFixture)

      @threadsReportView = new TuringEmailApp.Views.Reports.ThreadsReportView(
        model: @threadsReport
      )
      
      @threadsReport.fetch()

      @server.respond()

    afterEach ->
      @server.restore()

    it "should have the root element be a div", ->
      expect(@threadsReportView.el.nodeName).toEqual "DIV"

    it "should be defined", ->
      expect(TuringEmailApp.Views.Reports.ThreadsReportView).toBeDefined()

    it "should have the right model", ->
      expect(@threadsReportView.model).toEqual @threadsReport

    it "loads the threadsReport template", ->
      expect(@threadsReportView.template).toEqual JST["backbone/templates/reports/threads_report"]

    it "should show the average thread length", ->
      expect(@threadsReportView.$el.find("h4 small").text()).toEqual @threadsReport.get("average_thread_length").toString()

    it "should show the top email threads", ->
      subjects = []
      uids = []
      @threadsReportView.$el.find("ul li a").each ->
        uids.push $(@).attr("href").split("#")[2]
        subjects.push $(@).text()

      for email_thread, index in @threadsReport.get("top_email_threads")
        email_thread.uid
        expect(subjects[index]).toEqual email_thread.emails[0].subject
        expect(uids[index]).toEqual email_thread.uid
