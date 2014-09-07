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

  prepareDailyEmailVolumeDataOutput: (model) ->
    received_emails_per_day = model.get("received_emails_per_day")
    sent_emails_per_day = model.get("sent_emails_per_day")
    data_output = []
    data_output.push(['Day', 'Received', 'Sent'])
    current_day = new Date(Date.now())
    start = new Date(Date.now())
    start.setDate(start.getDate() - 30)
    while start < current_day
      date_string = start.getMonth() + 1 + "/" + start.getDate() + "/" + start.getFullYear()
      newDate = start.setDate(start.getDate() + 1)
      start = new Date(newDate)

      received_on_this_day = 0
      if date_string of received_emails_per_day
        received_on_this_day = received_emails_per_day[date_string]
      sent_on_this_day = 0
      if date_string of sent_emails_per_day
        sent_on_this_day = sent_emails_per_day[date_string]

      data_output.push([date_string, received_on_this_day, sent_on_this_day])
    return data_output

  prepareWeeklyEmailVolumeDataOutput: (model) ->
    received_emails_per_week = model.get("received_emails_per_week")
    sent_emails_per_week = model.get("sent_emails_per_week")
    data_output = []
    data_output.push(['Week', 'Received', 'Sent'])
    current_day = new Date(Date.now())
    start = new Date(Date.now())
    # Go to the start of the week.
    start.setDate(start.getDate() - start.getDay() + 1)
    # Go back 12 weeks.
    start.setDate(start.getDate() - 12 * 7)
    while start < current_day
      date_string = start.getMonth() + 1 + "/" + start.getDate() + "/" + start.getFullYear()
      newDate = start.setDate(start.getDate() + 7)
      start = new Date(newDate)

      received_on_this_week = 0
      if date_string of received_emails_per_week
        received_on_this_week = received_emails_per_week[date_string]
      sent_on_this_week = 0
      if date_string of sent_emails_per_week
        sent_on_this_week = sent_emails_per_week[date_string]

      data_output.push([date_string, received_on_this_week, sent_on_this_week])
    return data_output

  prepareMonthlyEmailVolumeDataOutput: (model) ->
    received_emails_per_month = model.get("received_emails_per_month")
    console.log received_emails_per_month
    sent_emails_per_month = model.get("sent_emails_per_month")
    console.log sent_emails_per_month
    data_output = []
    data_output.push(['Month', 'Received', 'Sent'])
    stop_date = new Date(Date.now())
    stop_date.setMonth(stop_date.getMonth() + 1)
    start = new Date(Date.now())
    start.setDate(start.getDate() - 356)
    while start < stop_date
      date_string = start.getMonth() + 1 + "/1/" + start.getFullYear()
      console.log date_string
      newDate = start.setMonth(start.getMonth() + 1)
      start = new Date(newDate)

      received_on_this_month = 0
      if date_string of received_emails_per_month
        received_on_this_month = received_emails_per_month[date_string]
      sent_on_this_month = 0
      if date_string of sent_emails_per_month
        sent_on_this_month = sent_emails_per_month[date_string]

      data_output.push([date_string, received_on_this_month, sent_on_this_month])
    return data_output

  showEmailVolumeReport: ->
    emailVolumeReport = new TuringEmailApp.Models.EmailVolumeReport()
    @.loadEmailVolumeReportSampleData emailVolumeReport
    emailVolumeReport.fetch(
      success: (model, response, options) =>
        #Prepare daily email volume data.

        dailyEmailVolumeData = { 
          data : @prepareDailyEmailVolumeDataOutput(model)
        }
        model.set "dailyEmailVolumeData", dailyEmailVolumeData
        
        weeklyEmailVolumeData = { 
          data : @prepareWeeklyEmailVolumeDataOutput(model)
        }
        model.set "weeklyEmailVolumeData", weeklyEmailVolumeData

        monthlyEmailVolumeData = { 
          data : @prepareMonthlyEmailVolumeDataOutput(model)
        }
        model.set "monthlyEmailVolumeData", monthlyEmailVolumeData

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
