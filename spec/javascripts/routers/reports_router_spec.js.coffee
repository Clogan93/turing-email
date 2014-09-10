describe "ReportsRouter", ->

  beforeEach ->
    @router = new TuringEmailApp.Routers.ReportsRouter
    @routeSpy = sinon.spy()
    try
      TuringEmailApp.start()

  it "has a analytics route and points to the showAnalytics method", ->
    expect(@router.routes["analytics"]).toEqual "showAnalytics"

  it "has a attachments_report route and points to the showAttachmentsReport method", ->
    expect(@router.routes["attachments_report"]).toEqual "showAttachmentsReport"

  it "has a email_volume_report route and points to the showEmailVolumeReport method", ->
    expect(@router.routes["email_volume_report"]).toEqual "showEmailVolumeReport"

  it "has a geo_report route and points to the showGeoReport method", ->
    expect(@router.routes["geo_report"]).toEqual "showGeoReport"

  it "has a impact_report route and points to the showImpactReport method", ->
    expect(@router.routes["impact_report"]).toEqual "showImpactReport"

  it "has a inbox_efficiency_report route and points to the showInboxEfficiencyReport method", ->
    expect(@router.routes["inbox_efficiency_report"]).toEqual "showInboxEfficiencyReport"

  it "has a lists_report route and points to the showListsReport method", ->
    expect(@router.routes["lists_report"]).toEqual "showListsReport"

  it "has a threads_report route and points to the showThreadsReport method", ->
    expect(@router.routes["threads_report"]).toEqual "showThreadsReport"

  it "has a top_senders_and_recipients_report route and points to the showTopSendersAndRecipientsReport method", ->
    expect(@router.routes["top_senders_and_recipients_report"]).toEqual "showTopSendersAndRecipientsReport"

  it "has a summary_analytics_report route and points to the showSummaryAnalyticsReport method", ->
    expect(@router.routes["summary_analytics_report"]).toEqual "showSummaryAnalyticsReport"

  it "has a word_count_report route and points to the showWordCountReport method", ->
    expect(@router.routes["word_count_report"]).toEqual "showWordCountReport"

  it "Has the right number of routes", ->
    expect(_.size(@router.routes)).toEqual 11
