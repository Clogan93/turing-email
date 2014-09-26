describe "WordCountReport", ->
  beforeEach ->
    wordCountFixtures = fixture.load("reports/word_count_report.fixture.json", true);
    @wordCountFixture = wordCountFixtures[0]

    @wordCountsReport = new TuringEmailApp.Models.WordCountReport()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_reports/word_count_report"
    @server.respondWith "GET", @url, JSON.stringify(@wordCountFixture)

  afterEach ->
    @server.restore()

  it "should have the right url", ->
    # currently using fake data
    #expect(@wordCountsReport.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @wordCountsReport.fetch()
      @server.respond()

    it "loads the contacts report", ->
      validateAttributes(@wordCountsReport.toJSON(), ["word_counts"])
