class TuringEmailApp.Routers.ReportsRouter extends Backbone.Router
  routes:
    "email_volume_report": "showEmailVolumeReport"
    "attachments_report": "showAttachmentsReport"
    "threads_report": "showThreadsReport"
    "inbox_efficiency_report": "showInboxEfficiencyReport"
    "word_count_report": "showWordCountReport"
    "summary_analytics_report": "showSummaryAnalyticsReport"

  loadEmailVolumeReportSampleData: (emailVolumeReport) ->
    emailVolumeReport.set "incomingEmailData", { 
      people : [
        ['David Gobaud', 3],
        ['Joe Blogs', 1],
        ['John Smith', 1],
        ['Marissa Mayer', 1],
        ['Elon Musk', 2]
      ],
      title : "Incoming Email Volume Chart"
    }
    emailVolumeReport.set "outgoingEmailData", { 
      people : [
        ['Edmund Curtis', 10],
        ['Stuart Cohen', 4],
        ['Nancy Rios', 3],
        ['Pamela White', 1],
        ['Joanne Park', 2]
      ],
      title : "Outgoing Email Volume Chart"
    }

  showEmailVolumeReport: ->
    emailVolumeReport = new TuringEmailApp.Models.EmailVolumeReport()
    this.loadEmailVolumeReportSampleData emailVolumeReport
    emailVolumeReportView = new TuringEmailApp.Views.Reports.EmailVolumeReportView(
      model: emailVolumeReport
      el: $("#reports")
    )
    emailVolumeReportView.render()

  showAttachmentsReport: ->
    attachmentsReport = new TuringEmailApp.Models.AttachmentsReport()
    attachmentsReportView = new TuringEmailApp.Views.Reports.AttachmentsReportView(
      model: attachmentsReport
      el: $("#reports")
    )
    attachmentsReportView.render()

  showThreadsReport: ->
    threadsReport = new TuringEmailApp.Models.ThreadsReport()
    threadsReportView = new TuringEmailApp.Views.Reports.ThreadsReportView(
      model: threadsReport
      el: $("#reports")
    )
    threadsReportView.render()

  showInboxEfficiencyReport: ->
    inboxEfficiencyReport = new TuringEmailApp.Models.InboxEfficiencyReport()
    inboxEfficiencyReportView = new TuringEmailApp.Views.Reports.InboxEfficiencyReportView(
      model: inboxEfficiencyReport
      el: $("#reports")
    )
    inboxEfficiencyReportView.render()

  showWordCountReport: ->
    wordCountReport = new TuringEmailApp.Models.WordCountReport()
    wordCountReportView = new TuringEmailApp.Views.Reports.WordCountReportView(
      model: wordCountReport
      el: $("#reports")
    )
    wordCountReportView.render()

  showSummaryAnalyticsReport: ->
    summaryAnalyticsReport = new TuringEmailApp.Models.SummaryAnalyticsReport()
    summaryAnalyticsReportView = new TuringEmailApp.Views.Reports.SummaryAnalyticsReportView(
      model: summaryAnalyticsReport
      el: $("#reports")
    )
    summaryAnalyticsReportView.render()
