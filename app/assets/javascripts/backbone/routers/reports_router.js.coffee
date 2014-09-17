class TuringEmailApp.Routers.ReportsRouter extends Backbone.Router
  routes:
    "attachments_report": "showAttachmentsReport"
    "email_volume_report": "showEmailVolumeReport"
    "geo_report": "showGeoReport"
    "impact_report": "showImpactReport"
    "inbox_efficiency_report": "showInboxEfficiencyReport"
    "lists_report": "showListsReport"
    "recommended_rules_report": "showRecommendedRulesReport"
    "threads_report": "showThreadsReport"
    "top_contacts": "showContactsReport"
    "summary_analytics_report": "showSummaryAnalyticsReport"
    "word_count_report": "showWordCountReport"

  #################################################################
  ###################### Loading Sample Data ######################
  #################################################################

  loadSummaryAnalyticsReportSampleData: (summaryAnalyticsReport) ->
    summaryAnalyticsReport.set "number_of_conversations", 824
    summaryAnalyticsReport.set "number_of_emails_received", 1039
    summaryAnalyticsReport.set "number_of_emails_sent", 203

  loadInboxEfficiencyReportSampleData: (inboxEfficiencyReport) ->
    inboxEfficiencyReport.set "average_response_time_in_minutes", 7.5
    inboxEfficiencyReport.set "percent_archived", 71.2

  loadWordCountReportSampleData: (wordCountReport) ->
    wordCountReport.set "data", { 
      wordCountData : [
        ['Count', 'Received', 'Sent'],
        ['< 10',  33,      17],
        ['< 30',  4,      27],
        ['< 50',  3,       26],
        ['< 100',  11,      14],
        ['< 200',  14,      12],
        ['More',  34,      3]
      ]
    }

  ##################################################################
  ########################## Show Reports ##########################
  ##################################################################

  showAttachmentsReport: (target_element = "#reports") ->
    attachmentsReport = new TuringEmailApp.Models.AttachmentsReport()
    
    attachmentsReport.fetch(
      success: (model, response, options) =>
        attachmentsReportView = new TuringEmailApp.Views.Reports.AttachmentsReportView(
          model: model
          el: $(target_element)
        )
        
        attachmentsReportView.render()
    )

  showEmailVolumeReport: (target_element = "#reports") ->
    emailVolumeReport = new TuringEmailApp.Models.EmailVolumeReport()
    
    emailVolumeReport.fetch(
      success: (model, response, options) =>
        emailVolumeReportView = new TuringEmailApp.Views.Reports.EmailVolumeReportView(
          model: model
          el: $(target_element)
        )
        emailVolumeReportView.render()
    )

  showGeoReport: (target_element = "#reports") ->
    geoReport = new TuringEmailApp.Models.GeoReport()

    geoReport.fetch(
      success: (model, response, options) ->
        geoReportView = new TuringEmailApp.Views.Reports.GeoReportView(
          model: model
          el: $(target_element)
        )
        
        geoReportView.render()
    )

  showImpactReport: (target_element="#reports") ->
    impactReport = new TuringEmailApp.Models.ImpactReport()

    impactReport.fetch(
      success: (model, response, options) =>
        impactReportView = new TuringEmailApp.Views.Reports.ImpactReportView(
          model: impactReport
          el: $(target_element)
        )
        
        impactReportView.render()
    )

  showInboxEfficiencyReport: (target_element="#reports") ->
    inboxEfficiencyReport = new TuringEmailApp.Models.InboxEfficiencyReport()
    @loadInboxEfficiencyReportSampleData inboxEfficiencyReport
    
    inboxEfficiencyReportView = new TuringEmailApp.Views.Reports.InboxEfficiencyReportView(
      model: inboxEfficiencyReport
      el: $(target_element)
    )
    
    inboxEfficiencyReportView.render()

  showListsReport: (target_element="#reports") ->
    listsReport = new TuringEmailApp.Models.ListsReport()
    
    listsReport.fetch(
      success: (model, response, options) =>
        listsReportView = new TuringEmailApp.Views.Reports.ListsReportView(
          model: model
          el: $(target_element)
        )
        
        listsReportView.render()
    )

  showRecommendedRulesReport: (target_element="#reports") ->
    recommendedRulesReport = new TuringEmailApp.Models.RecommendedRulesReport()

    recommendedRulesReport.fetch(
      success: (model, response, options) =>
        recommendedRulesReportView = new TuringEmailApp.Views.Reports.RecommendedRulesReportView(
          model: model
          el: $(target_element)
        )

        recommendedRulesReportView.render()
    ) 

  showSummaryAnalyticsReport: (target_element="#reports") ->
    summaryAnalyticsReport = new TuringEmailApp.Models.SummaryAnalyticsReport()
    @loadSummaryAnalyticsReportSampleData summaryAnalyticsReport
    
    summaryAnalyticsReportView = new TuringEmailApp.Views.Reports.SummaryAnalyticsReportView(
      model: summaryAnalyticsReport
      el: $(target_element)
    )
    
    summaryAnalyticsReportView.render()

  showThreadsReport: (target_element="#reports") ->
    threadsReport = new TuringEmailApp.Models.ThreadsReport()
    
    threadsReport.fetch(
      success: (model, response, options) =>
        threadsReportView = new TuringEmailApp.Views.Reports.ThreadsReportView(
          model: threadsReport
          el: $(target_element)
        )
        
        threadsReportView.render()
    )

  showContactsReport: (target_element="#reports") ->
    contactsReport = new TuringEmailApp.Models.ContactsReport()
    
    contactsReport.fetch(
      success: (model, response, options) =>
        contactsReportView = new TuringEmailApp.Views.Reports.ContactsReportView(
          model: contactsReport
          el: $(target_element)
        )
        
        contactsReportView.render()
    )

  showWordCountReport: (target_element="#reports") ->
    wordCountReport = new TuringEmailApp.Models.WordCountReport()
    @loadWordCountReportSampleData wordCountReport
    
    wordCountReportView = new TuringEmailApp.Views.Reports.WordCountReportView(
      model: wordCountReport
      el: $(target_element)
    )
    
    wordCountReportView.render()

  #TODO: re-factor mail.html.erb so that this is not longer necessary.
  restyle_other_elements: ->
    $("#preview_panel").hide()
    $(".mail-box-header").hide()
    $("table.table-mail").hide()
    $("#pages").hide()
    $("#email_table").hide()
    $("#preview_pane").hide()
    $(".main_email_list_content").css("height", "100%")
