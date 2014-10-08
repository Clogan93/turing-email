describe "AnalyticsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @reportsDiv = $("<div />", {id: "reports"}).appendTo("body")
    @analyticsView = new TuringEmailApp.Views.AnalyticsView(
      el: $("#reports")
    )

    attachmentsReportFixtures = fixture.load("reports/attachments_report.fixture.json", true);
    @attachmentsReportFixture = attachmentsReportFixtures[0]
    
    emailVolumeReportFixtures = fixture.load("reports/email_volume_report.fixture.json", true);
    @emailVolumeReportFixture = emailVolumeReportFixtures[0]

    geoReportFixtures = fixture.load("reports/geo_report.fixture.json", true);
    @geoReportFixture = geoReportFixtures[0]
    
    threadsFixtures = fixture.load("reports/threads_report.fixture.json", true);
    @threadsFixture = threadsFixtures[0]
    
    listsFixtures = fixture.load("reports/lists_report.fixture.json", true);
    @listsFixture = listsFixtures[0]
    
    contactsReportFixtures = fixture.load("reports/contacts_report.fixture.json", true);
    @contactsReportFixture = contactsReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.AttachmentsReport().url, JSON.stringify(@attachmentsReportFixture)
    @server.respondWith "GET", new TuringEmailApp.Models.EmailVolumeReport().url, JSON.stringify(@emailVolumeReportFixture)
    @server.respondWith "GET", new TuringEmailApp.Models.GeoReport().url, JSON.stringify(@geoReportFixture)
    @server.respondWith "GET", new TuringEmailApp.Models.ThreadsReport().url, JSON.stringify(@threadsFixture)
    @server.respondWith "GET", new TuringEmailApp.Models.ListsReport().url, JSON.stringify(@listsFixture)
    @server.respondWith "GET", new TuringEmailApp.Models.ContactsReport().url, JSON.stringify(@contactsReportFixture)

  afterEach ->
    @server.restore()
    @reportsDiv.remove()

    specStopTuringEmailApp()
    
  it "has the right template", ->
    expect(@analyticsView.template).toEqual JST["backbone/templates/analytics"]

  describe "#render", ->
    beforeEach ->
      @analyticsView.render()
      @server.respond()
    
    it "renders the reports", ->
      expect(@reportsDiv).toBeVisible()
      
      reportDivIDs = ["attachments_report", "email_volume_report", "geo_report"
                      "lists_report", "threads_report", "contacts_report"]

      for reportDivID in reportDivIDs
        reportDiv = $("#" + reportDivID)
        expect(reportDiv).toBeVisible()
