describe "Threads report model", ->

  beforeEach ->
    @threads_report = new TuringEmailApp.Models.ThreadsReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.ThreadsReport).toBeDefined()

  it "should have the right url", ->
    expect(@threads_report.url).toEqual '/api/v1/emails/threads_report'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("reports/threads_report.fixture.json", true);

      @threadsReport = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/emails/threads_report", JSON.stringify(@threadsReport)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @threads_report.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/emails/threads_report"
      return

    it "should parse the attributes from the response", ->
      @threads_report.fetch()
      @server.respond()

      expect(@threads_report.get("average_thread_length")).toEqual @threadsReport.average_thread_length
      expect(@threads_report.get("top_email_threads")).toEqual @threadsReport.top_email_threads
      return

    it "should have the attributes", ->
      @threads_report.fetch()
      @server.respond()

      expect(@threads_report.get("average_thread_length")).toBeDefined()
      expect(@threads_report.get("top_email_threads")).toBeDefined()
      return
