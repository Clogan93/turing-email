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

  loadAttachmentsReportSampleData: (attachmentsReport) ->
    attachmentsReport.set "data", { 
      attachmentData : [
        ['Year', 'Sent', 'Received'],
        ['docs',  10,      1],
        ['pdfs',  15,      4],
        ['images',  6,       11],
        ['zip',  10,      5]
      ]
    }

  loadSummaryAnalyticsReportSampleData: (summaryAnalyticsReport) ->
    summaryAnalyticsReport.set "number_of_conversations", 824
    summaryAnalyticsReport.set "number_of_emails_received", 1039
    summaryAnalyticsReport.set "number_of_emails_sent", 203

  loadInboxEfficiencyReportSampleData: (inboxEfficiencyReport) ->
    inboxEfficiencyReport.set "average_response_time_in_minutes", 7.5
    inboxEfficiencyReport.set "percent_archived", 71.2

  loadThreadsReportSampleData: (threadsReport) ->
    threadsReport.set "data", { 
      threadsData : [
        ['Age', 'Weight'],
        [ 8,      12],
        [ 4,      5.5],
        [ 11,     14],
        [ 4,      5],
        [ 3,      3.5],
        [ 6.5,    7]
      ]
    }

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

  showEmailVolumeReport: ->
    emailVolumeReport = new TuringEmailApp.Models.EmailVolumeReport()
    @.loadEmailVolumeReportSampleData emailVolumeReport
    emailVolumeReportView = new TuringEmailApp.Views.Reports.EmailVolumeReportView(
      model: emailVolumeReport
      el: $("#reports")
    )
    emailVolumeReportView.render()

  showAttachmentsReport: ->
    attachmentsReport = new TuringEmailApp.Models.AttachmentsReport()
    @.loadAttachmentsReportSampleData attachmentsReport
    attachmentsReportView = new TuringEmailApp.Views.Reports.AttachmentsReportView(
      model: attachmentsReport
      el: $("#reports")
    )
    attachmentsReportView.render()

  showThreadsReport: ->
    threadsReport = new TuringEmailApp.Models.ThreadsReport()
    @.loadThreadsReportSampleData threadsReport
    threadsReportView = new TuringEmailApp.Views.Reports.ThreadsReportView(
      model: threadsReport
      el: $("#reports")
    )
    threadsReportView.render()

  showInboxEfficiencyReport: ->
    inboxEfficiencyReport = new TuringEmailApp.Models.InboxEfficiencyReport()
    @.loadInboxEfficiencyReportSampleData inboxEfficiencyReport
    inboxEfficiencyReportView = new TuringEmailApp.Views.Reports.InboxEfficiencyReportView(
      model: inboxEfficiencyReport
      el: $("#reports")
    )
    inboxEfficiencyReportView.render()

  showWordCountReport: ->
    wordCountReport = new TuringEmailApp.Models.WordCountReport()
    @.loadWordCountReportSampleData wordCountReport
    wordCountReportView = new TuringEmailApp.Views.Reports.WordCountReportView(
      model: wordCountReport
      el: $("#reports")
    )
    wordCountReportView.render()

  showSummaryAnalyticsReport: ->
    summaryAnalyticsReport = new TuringEmailApp.Models.SummaryAnalyticsReport()
    @.loadSummaryAnalyticsReportSampleData summaryAnalyticsReport
    summaryAnalyticsReportView = new TuringEmailApp.Views.Reports.SummaryAnalyticsReportView(
      model: summaryAnalyticsReport
      el: $("#reports")
    )
    summaryAnalyticsReportView.render()
