describe "ThreadsReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @threadsReport = new TuringEmailApp.Models.Reports.ThreadsReport()

    @threadsReportView = new TuringEmailApp.Views.Reports.ThreadsReportView(
      model: @threadsReport
    )

    threadsReportFixtures = fixture.load("reports/threads_report.fixture.json", true);
    @threadsReportFixture = threadsReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.Reports.ThreadsReport().url, JSON.stringify(@threadsReportFixture)

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@threadsReportView.template).toEqual JST["backbone/templates/reports/threads_report"]

  describe "#render", ->
    beforeEach ->
      @threadsReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@threadsReportView.$el).toContainHtml("Threads")
      
    it "renders the average thread length", ->
      expect(@threadsReportView.$el).toContainHtml('<h4 class="h4">Average Thread Length: <small>' +
                                              @threadsReport.get("average_thread_length") +
                                              '</small></h4>')
      
    it "renders the top email threads", ->
      expect(@threadsReportView.$el).toContainHtml('<h4 class="h4">Top Email Threads</h4>')
      
      for emailThread, index in @threadsReport.get("top_email_threads")
        expect(@threadsReportView.$el).toContainHtml('<li><a href="#email_thread/' + emailThread.uid + '">' +
                                                   emailThread.emails[0].subject + '</a></li>')
