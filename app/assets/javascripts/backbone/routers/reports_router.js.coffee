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
    "top_contacts": "showTopContactsReport"
    "summary_analytics_report": "showSummaryAnalyticsReport"
    "word_count_report": "showWordCountReport"

  showAttachmentsReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.AttachmentsReport, TuringEmailApp.Views.Reports.AttachmentsReportView

  showEmailVolumeReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.EmailVolumeReport, TuringEmailApp.Views.Reports.EmailVolumeReportView

  showGeoReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.GeoReport, TuringEmailApp.Views.Reports.GeoReportView

  showImpactReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.ImpactReport, TuringEmailApp.Views.Reports.ImpactReportView

  showListsReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.ListsReport, TuringEmailApp.Views.Reports.ListsReportView

  showRecommendedRulesReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.RecommendedRulesReport, TuringEmailApp.Views.Reports.RecommendedRulesReportView

  showThreadsReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.ThreadsReport, TuringEmailApp.Views.Reports.ThreadsReportView

  showTopContactsReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.ContactsReport, TuringEmailApp.Views.Reports.ContactsReportView

  ##################################################################
  ########################## Show Reports ##########################
  ##################################################################

  showReport: (divReportsID, ReportModel, ReportView) ->
    reportModel = new ReportModel()
    reportView = new ReportView(
      model: reportModel
      el: $("#" + divReportsID)
    )

    reportModel.fetch()
    
  #################################################################
  ################### Sample Data Based Reports ###################
  #################################################################

  showInboxEfficiencyReport: (target_element="reports") ->
    inboxEfficiencyReport = new TuringEmailApp.Models.InboxEfficiencyReport()
    @loadInboxEfficiencyReportSampleData inboxEfficiencyReport
    
    inboxEfficiencyReportView = new TuringEmailApp.Views.Reports.InboxEfficiencyReportView(
      model: inboxEfficiencyReport
      el: $(target_element)
    )

    inboxEfficiencyReportView.render()

  loadInboxEfficiencyReportSampleData: (inboxEfficiencyReport) ->
    inboxEfficiencyReport.set "average_response_time_in_minutes", 7.5
    inboxEfficiencyReport.set "percent_archived", 71.2

  showSummaryAnalyticsReport: (target_element="reports") ->
    summaryAnalyticsReport = new TuringEmailApp.Models.SummaryAnalyticsReport()
    @loadSummaryAnalyticsReportSampleData summaryAnalyticsReport
    
    summaryAnalyticsReportView = new TuringEmailApp.Views.Reports.SummaryAnalyticsReportView(
      model: summaryAnalyticsReport
      el: $(target_element)
    )

    summaryAnalyticsReportView.render()

  loadSummaryAnalyticsReportSampleData: (summaryAnalyticsReport) ->
    summaryAnalyticsReport.set "number_of_conversations", 824
    summaryAnalyticsReport.set "number_of_emails_received", 1039
    summaryAnalyticsReport.set "number_of_emails_sent", 203

  showWordCountReport: (target_element="reports") ->
    wordCountReport = new TuringEmailApp.Models.WordCountReport()
    @loadWordCountReportSampleData wordCountReport
    
    wordCountReportView = new TuringEmailApp.Views.Reports.WordCountReportView(
      model: wordCountReport
      el: $(target_element)
    )
    
    wordCountReportView.render()

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
