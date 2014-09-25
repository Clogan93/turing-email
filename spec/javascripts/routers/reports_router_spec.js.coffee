describe "ReportsRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
    
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  it "has the expected routes", ->
    expect(@reportsRouter.routes["attachments_report"]).toEqual "showAttachmentsReport"
    expect(@reportsRouter.routes["email_volume_report"]).toEqual "showEmailVolumeReport"
    expect(@reportsRouter.routes["geo_report"]).toEqual "showGeoReport"
    expect(@reportsRouter.routes["impact_report"]).toEqual "showImpactReport"
    expect(@reportsRouter.routes["inbox_efficiency_report"]).toEqual "showInboxEfficiencyReport"
    expect(@reportsRouter.routes["lists_report"]).toEqual "showListsReport"
    expect(@reportsRouter.routes["recommended_rules_report"]).toEqual "showRecommendedRulesReport"
    expect(@reportsRouter.routes["threads_report"]).toEqual "showThreadsReport"
    expect(@reportsRouter.routes["top_contacts"]).toEqual "showTopContactsReport"
    expect(@reportsRouter.routes["summary_analytics_report"]).toEqual "showSummaryAnalyticsReport"
    expect(@reportsRouter.routes["word_count_report"]).toEqual "showWordCountReport"

  describe "attachments_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.Reports, "AttachmentsReportView")
      @reportsRouter.navigate "attachments_report", trigger: true
    
    afterEach ->
      @spy.restore()
    
    it "shows an AttachmentsReportView", ->
      expect(@spy.called).toBeTruthy()

  describe "email_volume_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.Reports, "EmailVolumeReportView")
      @reportsRouter.navigate "email_volume_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows an EmailVolumeReportView", ->
      expect(@spy.called).toBeTruthy()

  describe "geo_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.Reports, "GeoReportView")
      @reportsRouter.navigate "geo_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a GeoReportView", ->
      expect(@spy.called).toBeTruthy()

  describe "impact_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.Reports, "ImpactReportView")
      @reportsRouter.navigate "impact_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows an ImpactReportView", ->
      expect(@spy.called).toBeTruthy()

  describe "inbox_efficiency_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.Reports, "InboxEfficiencyReportView")
      @reportsRouter.navigate "inbox_efficiency_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows an InboxEfficiencyReportView", ->
      expect(@spy.called).toBeTruthy()

  describe "lists_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.Reports, "ListsReportView")
      @reportsRouter.navigate "lists_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a ListsReportView", ->
      expect(@spy.called).toBeTruthy()

  describe "recommended_rules_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.Reports, "RecommendedRulesReportView")
      @reportsRouter.navigate "recommended_rules_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a RecommendedRulesReportView", ->
      expect(@spy.called).toBeTruthy()

  describe "threads_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.Reports, "ThreadsReportView")
      @reportsRouter.navigate "threads_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a ThreadsReportView", ->
      expect(@spy.called).toBeTruthy()

  describe "top_contacts", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.Reports, "ContactsReportView")
      @reportsRouter.navigate "top_contacts", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a ContactsReportView", ->
      expect(@spy.called).toBeTruthy()

  describe "summary_analytics_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.Reports, "SummaryAnalyticsReportView")
      @reportsRouter.navigate "summary_analytics_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a SummaryAnalyticsReportView", ->
      expect(@spy.called).toBeTruthy()

  describe "word_count_report", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.Reports, "WordCountReportView")
      @reportsRouter.navigate "word_count_report", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a WordCountReportView", ->
      expect(@spy.called).toBeTruthy()
