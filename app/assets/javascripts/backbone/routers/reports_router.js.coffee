class TuringEmailApp.Routers.ReportsRouter extends Backbone.Router
  routes:
    "attachments_report": "showAttachmentsReport"
    "email_volume_report": "showEmailVolumeReport"
    "geo_report": "showGeoReport"
    "impact_report": "showImpactReport"
    "inbox_efficiency_report": "showInboxEfficiencyReport"
    "lists_report": "showListsReport"
    "recommended_rules_report": "showRecommendedRulesReport"
    "summary_analytics_report": "showSummaryAnalyticsReport"
    "threads_report": "showThreadsReport"
    "top_contacts": "showTopContactsReport"
    "word_count_report": "showWordCountReport"

  showReport: (divReportsID, ReportModel, ReportView) ->
    reportModel = new ReportModel()
    reportView = new ReportView(
      model: reportModel
      el: $("#" + divReportsID)
    )

    reportModel.fetch()
    
  showAttachmentsReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.AttachmentsReport, TuringEmailApp.Views.Reports.AttachmentsReportView

  showEmailVolumeReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.EmailVolumeReport, TuringEmailApp.Views.Reports.EmailVolumeReportView

  showGeoReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.GeoReport, TuringEmailApp.Views.Reports.GeoReportView

  showImpactReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.ImpactReport, TuringEmailApp.Views.Reports.ImpactReportView

  showInboxEfficiencyReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.InboxEfficiencyReport, TuringEmailApp.Views.Reports.InboxEfficiencyReportView

  showListsReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.ListsReport, TuringEmailApp.Views.Reports.ListsReportView

  showRecommendedRulesReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.RecommendedRulesReport, TuringEmailApp.Views.Reports.RecommendedRulesReportView

  showSummaryAnalyticsReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.SummaryAnalyticsReport, TuringEmailApp.Views.Reports.SummaryAnalyticsReportView

  showThreadsReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.ThreadsReport, TuringEmailApp.Views.Reports.ThreadsReportView

  showTopContactsReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.ContactsReport, TuringEmailApp.Views.Reports.ContactsReportView

  showWordCountReport: (divReportsID="reports") ->
    @showReport divReportsID, TuringEmailApp.Models.WordCountReport, TuringEmailApp.Views.Reports.WordCountReportView
