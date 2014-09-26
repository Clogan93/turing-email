describe "AnalyticsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @reportsDiv = $("<div />", {id: "reports"}).appendTo('body')
    @analyticsView = new TuringEmailApp.Views.AnalyticsView(
      el: $("#reports")
    )

    @server = sinon.fakeServer.create()

    attachmentsReportFixtures = fixture.load("reports/attachments_report.fixture.json", true);
    @attachmentsReportFixture = attachmentsReportFixtures[0]
    @server.respondWith "GET", "/api/v1/email_reports/attachments_report", JSON.stringify(@attachmentsReportFixture)
    
    emailVolumeReportFixtures = fixture.load("reports/email_volume_report.fixture.json", true);
    @emailVolumeReportFixture = emailVolumeReportFixtures[0]
    @server.respondWith "GET", "/api/v1/email_reports/volume_report", JSON.stringify(@emailVolumeReportFixture)
    
    geoReportFixtures = fixture.load("reports/geo_report.fixture.json", true);
    @geoReportFixture = geoReportFixtures[0]
    @server.respondWith "GET", "/api/v1/email_reports/ip_stats_report", JSON.stringify(@geoReportFixture)
    
    threadsFixtures = fixture.load("reports/threads_report.fixture.json", true);
    @threadsFixture = threadsFixtures[0]
    @server.respondWith "GET", "/api/v1/email_reports/threads_report", JSON.stringify(@threadsFixture)
    
    listsFixtures = fixture.load("reports/lists_report.fixture.json", true);
    @listsFixture = listsFixtures[0]
    @server.respondWith "GET", "/api/v1/email_reports/lists_report", JSON.stringify(@listsFixture)
    
    contactsReportFixtures = fixture.load("reports/contacts_report.fixture.json", true);
    @contactsReportFixture = contactsReportFixtures[0]
    @server.respondWith "GET", "/api/v1/email_reports/contacts_report", JSON.stringify(@contactsReportFixture)

  afterEach ->
    $(@reportsDiv).remove()
    
  it "has the right template", ->
    expect(@analyticsView.template).toEqual JST["backbone/templates/analytics"]

  describe "#render", ->
    beforeEach ->
      @analyticsView.render()
    
    it 'renders the reports', ->
      expect(@reportsDiv).toBeVisible()
      
      reportDivIDs = ["attachments_report", "email_volume_report", "geo_report"
                      "lists_report", "threads_report", "contacts_report"]
      
      for reportDivID in reportDivIDs
        reportDiv = $("#" + reportDivID)
        expect(reportDiv).toBeVisible()
