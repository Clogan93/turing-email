describe "ReportsRouter", ->

  beforeEach ->
    @router = new TuringEmailApp.Routers.ReportsRouter()
    @routeSpy = sinon.spy()
    try
      Backbone.history.start
        silent: true

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

  it "has a top_contacts route and points to the showContactsReport method", ->
    expect(@router.routes["top_contacts"]).toEqual "showContactsReport"

  it "has a summary_analytics_report route and points to the showSummaryAnalyticsReport method", ->
    expect(@router.routes["summary_analytics_report"]).toEqual "showSummaryAnalyticsReport"

  it "has a word_count_report route and points to the showWordCountReport method", ->
    expect(@router.routes["word_count_report"]).toEqual "showWordCountReport"

  it "Has the right number of routes", ->
    expect(_.size(@router.routes)).toEqual 11

  it "fires the showAttachmentsReport route with attachments_report", ->
    @router.bind "route:showAttachmentsReport", @routeSpy
    @router.navigate "attachments_report",
      trigger: true
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith()
    return

  it "fires the showEmailVolumeReport route with email_volume_report", ->
    @router.bind "route:showEmailVolumeReport", @routeSpy
    @router.navigate "email_volume_report",
      trigger: true
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith()
    return

  it "fires the showGeoReport route with geo_report", ->
    @router.bind "route:showGeoReport", @routeSpy
    @router.navigate "geo_report",
      trigger: true
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith()
    return

  it "fires the showImpactReport route with impact_report", ->
    @router.bind "route:showImpactReport", @routeSpy
    @router.navigate "impact_report",
      trigger: true
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith()
    return

  it "fires the showListsReport route with lists_report", ->
    @router.bind "route:showListsReport", @routeSpy
    @router.navigate "lists_report",
      trigger: true
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith()
    return

  it "fires the showRecommendedRulesReport route with recommended_rules_report", ->
    @router.bind "route:showRecommendedRulesReport", @routeSpy
    @router.navigate "recommended_rules_report",
      trigger: true
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith()
    return

  it "fires the showThreadsReport route with threads_report", ->
    @router.bind "route:showThreadsReport", @routeSpy
    @router.navigate "threads_report",
      trigger: true
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith()
    return

  it "fires the showContactsReport route with top_contacts", ->
    @router.bind "route:showContactsReport", @routeSpy
    @router.navigate "top_contacts",
      trigger: true
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith()
    return
