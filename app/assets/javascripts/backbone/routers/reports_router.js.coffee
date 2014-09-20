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

  ##################################################################
  ########################## Show Reports ##########################
  ##################################################################

  showReport: (target_element = "#reports", ReportModel, ReportView) ->
    reportModel = new ReportModel()
    reportView = new ReportView(
      model: reportModel
      el: $(target_element)
    )

    reportModel.fetch()

  showAttachmentsReport: ->
    @showReport "#reports", TuringEmailApp.Models.AttachmentsReport, TuringEmailApp.Views.Reports.AttachmentsReportView

  showEmailVolumeReport: ->
    @showReport "#reports", TuringEmailApp.Models.EmailVolumeReport, TuringEmailApp.Views.Reports.EmailVolumeReportView

  showGeoReport: ->
    @showReport "#reports", TuringEmailApp.Models.GeoReport, TuringEmailApp.Views.Reports.GeoReportView

  showImpactReport: ->
    @showReport "#reports", TuringEmailApp.Models.ImpactReport, TuringEmailApp.Views.Reports.ImpactReportView

  showListsReport: ->
    @showReport "#reports", TuringEmailApp.Models.ListsReport, TuringEmailApp.Views.Reports.ListsReportView

  showRecommendedRulesReport: ->
    @showReport "#reports", TuringEmailApp.Models.RecommendedRulesReport, TuringEmailApp.Views.Reports.RecommendedRulesReportView

  showThreadsReport: ->
    @showReport "#reports", TuringEmailApp.Models.ThreadsReport, TuringEmailApp.Views.Reports.ThreadsReportView

  showContactsReport: ->
    @showReport "#reports", TuringEmailApp.Models.ContactsReport, TuringEmailApp.Views.Reports.ContactsReportView

  #################################################################
  ########################### Re-styling ##########################
  #################################################################

  #TODO: re-factor mail.html.erb so that this is not longer necessary.
  restyle_other_elements: ->
    $("#preview_panel").hide()
    $(".mail-box-header").hide()
    $("table.table-mail").hide()
    $("#pages").hide()
    $("#email_table").hide()
    $("#preview_pane").hide()
    $(".main_email_list_content").css("height", "100%")

  #################################################################
  ################### Sample Data Based Reports ###################
  #################################################################

  showInboxEfficiencyReport: (target_element="#reports") ->
    @showReport "#reports", TuringEmailApp.Models.ImpactReport, TuringEmailApp.Views.Reports.ImpactReportView
    inboxEfficiencyReport = new TuringEmailApp.Models.InboxEfficiencyReport()
    @loadInboxEfficiencyReportSampleData inboxEfficiencyReport
    
    inboxEfficiencyReportView = new TuringEmailApp.Views.Reports.InboxEfficiencyReportView(
      model: inboxEfficiencyReport
      el: $(target_element)
    )
    
    inboxEfficiencyReport.fetch()

  loadInboxEfficiencyReportSampleData: (inboxEfficiencyReport) ->
    inboxEfficiencyReport.set "average_response_time_in_minutes", 7.5
    inboxEfficiencyReport.set "percent_archived", 71.2

  showSummaryAnalyticsReport: (target_element="#reports") ->
    summaryAnalyticsReport = new TuringEmailApp.Models.SummaryAnalyticsReport()
    @loadSummaryAnalyticsReportSampleData summaryAnalyticsReport
    
    summaryAnalyticsReportView = new TuringEmailApp.Views.Reports.SummaryAnalyticsReportView(
      model: summaryAnalyticsReport
      el: $(target_element)
    )
    
    summaryAnalyticsReport.render()

  loadSummaryAnalyticsReportSampleData: (summaryAnalyticsReport) ->
    summaryAnalyticsReport.set "number_of_conversations", 824
    summaryAnalyticsReport.set "number_of_emails_received", 1039
    summaryAnalyticsReport.set "number_of_emails_sent", 203

  showWordCountReport: (target_element="#reports") ->
    wordCountReport = new TuringEmailApp.Models.WordCountReport()
    @loadWordCountReportSampleData wordCountReport
    
    wordCountReportView = new TuringEmailApp.Views.Reports.WordCountReportView(
      model: wordCountReport
      el: $(target_element)
    )
    
    wordCountReport.fetch()

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
