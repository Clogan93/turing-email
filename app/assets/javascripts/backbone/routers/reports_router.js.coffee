class TuringEmailApp.Routers.ReportsRouter extends Backbone.Router
  routes:
    "attachments_report": "showAttachmentsReport"
    "email_volume_report": "showEmailVolumeReport"
    "geo_report": "showGeoReport"
    "inbox_efficiency_report": "showInboxEfficiencyReport"
    "threads_report": "showThreadsReport"
    "top_senders_and_recipients_report": "showTopSendersAndRecipientsReport"
    "summary_analytics_report": "showSummaryAnalyticsReport"
    "word_count_report": "showWordCountReport"

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

  loadEmailVolumeReportSampleData: (emailVolumeReport) ->
    emailVolumeReport.set "dailyEmailVolumeData", { 
      data : [
        ['Day', 'Received', 'Sent'],
        ['2013',  1000,      400],
        ['2014',  1170,      460],
        ['2015',  660,       1120],
        ['2016',  1030,      540]
      ]
    }
    emailVolumeReport.set "weeklyEmailVolumeData", {
      data : [
        ['Week', 'Received', 'Sent'],
        ['2013',  1000,      400],
        ['2014',  1170,      460],
        ['2015',  660,       1120],
        ['2016',  1030,      540]
      ]
    }
    emailVolumeReport.set "monthlyEmailVolumeData", {
      data : [
        ['Month', 'Received', 'Sent'],
        ['2013',  1000,      400],
        ['2014',  1170,      460],
        ['2015',  660,       1120],
        ['2016',  1030,      540]
      ]
    }

  loadTopSendersAndRecipientsReportSampleData: (topSendersAndRecipientsReport) ->
    topSendersAndRecipientsReport.set "incomingEmailData", { 
      people : [
        ['David Gobaud', 3],
        ['Joe Blogs', 1],
        ['John Smith', 1],
        ['Marissa Mayer', 1],
        ['Elon Musk', 2]
      ],
      title : "Incoming Email Volume Chart"
    }
    topSendersAndRecipientsReport.set "outgoingEmailData", {
      people : [
        ['Edmund Curtis', 10],
        ['Stuart Cohen', 4],
        ['Nancy Rios', 3],
        ['Pamela White', 1],
        ['Joanne Park', 2]
      ],
      title : "Outgoing Email Volume Chart"
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

  showAttachmentsReport: ->
    attachmentsReport = new TuringEmailApp.Models.AttachmentsReport()
    @.loadAttachmentsReportSampleData attachmentsReport
    attachmentsReportView = new TuringEmailApp.Views.Reports.AttachmentsReportView(
      model: attachmentsReport
      el: $("#reports")
    )
    attachmentsReportView.render()

  showEmailVolumeReport: ->
    emailVolumeReport = new TuringEmailApp.Models.EmailVolumeReport()
    @.loadEmailVolumeReportSampleData emailVolumeReport
    emailVolumeReport.fetch(
      success: (model, response, options) ->
        #Prepare daily email volume data.

        current_day = new Date()
        d = current_day
        for num_days in [0...30]
          d.setDate(d.getDate()-num_days)
          utc_string = d.toUTCString()
          d.setHours(0)
          console.log utc_string.replace "GMT", "-0000"

        console.log "Hello"
        console.log model.get("received_emails_per_day")
        console.log model.get("sent_emails_per_day")
        console.log model
        console.log "world!"

        dailyEmailVolumeData = { 
          data : [
            ['Day', 'Received', 'Sent'],
            ['2013',  1000,      400],
            ['2014',  1170,      460],
            ['2015',  660,       1120],
            ['2016',  1030,      540]
          ]
        }
        weeklyEmailVolumeData = {
          data : [
            ['Week', 'Received', 'Sent'],
            ['March 1st',  1000,      400],
            ['March 8th',  1170,      460],
            ['March 15th',  660,       1120],
            ['March 22nd',  1030,      540]
          ]
        }
        monthlyEmailVolumeData = {
          data : [
            ['Month', 'Received', 'Sent'],
            ['January',  1000,      400],
            ['February',  1170,      460],
            ['March',  660,       1120],
            ['Apri',  1030,      540]
          ]
        }
        # for key, geoDataPoint of model.attributes
        #   data.geoData.push([geoDataPoint["ip_info"]["city"], geoDataPoint["num_emails"]])
        # model.set "data", data

        emailVolumeReportView = new TuringEmailApp.Views.Reports.EmailVolumeReportView(
          model: model
          el: $("#reports")
        )
        emailVolumeReportView.render()
    )

  showGeoReport: ->
    geoReport = new TuringEmailApp.Models.GeoReport()
    geoReport.fetch(
      success: (model, response, options) ->
        data = { 
          geoData : [
            ['City', 'Popularity']
          ]
        }
        for key, geoDataPoint of model.attributes
          data.geoData.push([geoDataPoint["ip_info"]["city"], geoDataPoint["num_emails"]])
        model.set "data", data

        geoReportView = new TuringEmailApp.Views.Reports.GeoReportView(
          model: model
          el: $("#reports")
        )
        geoReportView.render()
    )

  showInboxEfficiencyReport: ->
    inboxEfficiencyReport = new TuringEmailApp.Models.InboxEfficiencyReport()
    @.loadInboxEfficiencyReportSampleData inboxEfficiencyReport
    inboxEfficiencyReportView = new TuringEmailApp.Views.Reports.InboxEfficiencyReportView(
      model: inboxEfficiencyReport
      el: $("#reports")
    )
    inboxEfficiencyReportView.render()

  showSummaryAnalyticsReport: ->
    summaryAnalyticsReport = new TuringEmailApp.Models.SummaryAnalyticsReport()
    @.loadSummaryAnalyticsReportSampleData summaryAnalyticsReport
    summaryAnalyticsReportView = new TuringEmailApp.Views.Reports.SummaryAnalyticsReportView(
      model: summaryAnalyticsReport
      el: $("#reports")
    )
    summaryAnalyticsReportView.render()

  showThreadsReport: ->
    threadsReport = new TuringEmailApp.Models.ThreadsReport()
    @.loadThreadsReportSampleData threadsReport
    threadsReportView = new TuringEmailApp.Views.Reports.ThreadsReportView(
      model: threadsReport
      el: $("#reports")
    )
    threadsReportView.render()

  showTopSendersAndRecipientsReport: ->
    topSendersAndRecipientsReport = new TuringEmailApp.Models.TopSendersAndRecipientsReport()
    @.loadTopSendersAndRecipientsReportSampleData topSendersAndRecipientsReport
    topSendersAndRecipientsReportView = new TuringEmailApp.Views.Reports.TopSendersAndRecipientsReportView(
      model: topSendersAndRecipientsReport
      el: $("#reports")
    )
    topSendersAndRecipientsReportView.render()

  showWordCountReport: ->
    wordCountReport = new TuringEmailApp.Models.WordCountReport()
    @.loadWordCountReportSampleData wordCountReport
    wordCountReportView = new TuringEmailApp.Views.Reports.WordCountReportView(
      model: wordCountReport
      el: $("#reports")
    )
    wordCountReportView.render()
