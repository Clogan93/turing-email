class TuringEmailApp.Routers.ReportsRouter extends Backbone.Router
  routes:
    "attachments_report": "showAttachmentsReport"
    "email_volume_report": "showEmailVolumeReport"
    "folders_report": "showFoldersReport"
    "geo_report": "showGeoReport"
    "impact_report": "showImpactReport"
    "inbox_efficiency_report": "showInboxEfficiencyReport"
    "lists_report": "showListsReport"
    "recommended_rules_report": "showRecommendedRulesReport"
    "summary_analytics_report": "showSummaryAnalyticsReport"
    "threads_report": "showThreadsReport"
    "top_contacts": "showTopContactsReport"
    "word_count_report": "showWordCountReport"

  showAttachmentsReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.AttachmentsReport,
                              TuringEmailApp.Views.Reports.AttachmentsReportView)

  showEmailVolumeReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.EmailVolumeReport,
                              TuringEmailApp.Views.Reports.EmailVolumeReportView)

  showFoldersReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.FoldersReport,
                              TuringEmailApp.Views.Reports.FoldersReportView)

  showGeoReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.GeoReport,
                              TuringEmailApp.Views.Reports.GeoReportView)

  showImpactReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.ImpactReport,
                              TuringEmailApp.Views.Reports.ImpactReportView)

  showInboxEfficiencyReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.InboxEfficiencyReport,
                              TuringEmailApp.Views.Reports.InboxEfficiencyReportView)

  showListsReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.ListsReport,
                              TuringEmailApp.Views.Reports.ListsReportView)

  showRecommendedRulesReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.RecommendedRulesReport,
                              TuringEmailApp.Views.Reports.RecommendedRulesReportView)

  showSummaryAnalyticsReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.SummaryAnalyticsReport,
                              TuringEmailApp.Views.Reports.SummaryAnalyticsReportView)

  showThreadsReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.ThreadsReport,
                              TuringEmailApp.Views.Reports.ThreadsReportView)

  showTopContactsReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.ContactsReport,
                              TuringEmailApp.Views.Reports.ContactsReportView)

  showWordCountReport: (divReportsID) ->
    TuringEmailApp.showReport(divReportsID, TuringEmailApp.Models.Reports.WordCountReport,
                              TuringEmailApp.Views.Reports.WordCountReportView)
