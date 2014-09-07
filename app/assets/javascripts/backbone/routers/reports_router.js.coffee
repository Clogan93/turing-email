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
        ['Attachment Type', 'Number of attachments'],
        ['docs',  10],
        ['pdfs',  15],
        ['images',  6],
        ['zip',  10]
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

  translateContentType: (attachmentdata, header) ->
    newAttachmentsData = {}
    newAttachmentsData["Document"] = 0
    for attachmentData in attachmentdata
      content_type_parts = attachmentData[0].split("/")
      value = attachmentData[1]
      if content_type_parts[0] is "image"
        if newAttachmentsData["Images"]?
          newAttachmentsData["Images"] += value
        else 
          newAttachmentsData["Images"] = value
      else
        last_index = parseInt(content_type_parts.length) - 1
        content_type = content_type_parts[last_index]
        switch content_type
          when "ics" then newAttachmentsData["Calendar Invite"] = value
          when "pdf" then newAttachmentsData["PDF"] = value
          when "vnd.openxmlformats-officedocument.presentationml.presentation" then newAttachmentsData["Presentation"] = value
          when "vnd.openxmlformats-officedocument.spreadsheetml.sheet" then newAttachmentsData["Spreadsheet"] = value
          when "msword" then newAttachmentsData["Document"] += value
          when "vnd.openxmlformats-officedocument.wordprocessingml.document" then newAttachmentsData["Document"] += value
          when "zip" then newAttachmentsData["ZIP"] = value
          when "octet-stream" then newAttachmentsData["Binary"] = value
          else newAttachmentsData[content_type] = value; console.log content_type
    attachmentdata = []
    attachmentdata.push(header)
    for key, value of newAttachmentsData
      attachmentdata.push([key, value])
    return attachmentdata

  showAttachmentsReport: ->
    attachmentsReport = new TuringEmailApp.Models.AttachmentsReport()
    attachmentsReport.fetch(
      success: (model, response, options) =>

        data = { 
          numAttachmentsData : []
          averageFileSizeAttachmentsData : []
        }

        for content_type, stats of model.get("content_type_stats")
          data.numAttachmentsData.push([content_type, stats.num_attachments])
          data.averageFileSizeAttachmentsData.push([content_type, stats.average_file_size])

        data.numAttachmentsData = @translateContentType data.numAttachmentsData, ['Attachment Type', 'Number of attachments']
        data.averageFileSizeAttachmentsData = @translateContentType data.averageFileSizeAttachmentsData, ['Attachment Type', 'Average File Size']

        attachmentsReport.set "data", data

        attachmentsReportView = new TuringEmailApp.Views.Reports.AttachmentsReportView(
          model: model
          el: $("#reports")
        )
        attachmentsReportView.render()

    )

  prepareDailyEmailVolumeDataOutput: (model) ->
    receivedEmailsPerDay = model.get("received_emails_per_day")
    sentEmailsPerDay = model.get("sent_emails_per_day")
    dataOutput = []
    dataOutput.push(['Day', 'Received', 'Sent'])
    currentDay = new Date(Date.now())
    start = new Date(Date.now())
    start.setDate(start.getDate() - 30)
    while start < currentDay
      dateString = start.getMonth() + 1 + "/" + start.getDate() + "/" + start.getFullYear()
      newDate = start.setDate(start.getDate() + 1)
      start = new Date(newDate)

      receivedOnThisDay = 0
      if dateString of receivedEmailsPerDay
        receivedOnThisDay = receivedEmailsPerDay[dateString]
      sentOnThisDay = 0
      if dateString of sentEmailsPerDay
        sentOnThisDay = sentEmailsPerDay[dateString]

      dataOutput.push([dateString, receivedOnThisDay, sentOnThisDay])
    return dataOutput

  prepareWeeklyEmailVolumeDataOutput: (model) ->
    receivedEmailsPerWeek = model.get("received_emails_per_week")
    sentEmailsPerWeek = model.get("sent_emails_per_week")
    dataOutput = []
    dataOutput.push(['Week', 'Received', 'Sent'])
    currentDay = new Date(Date.now())
    start = new Date(Date.now())
    start.setDate(start.getDate() - start.getDay() + 1) # Go to the start of the week.
    numberOfDaysToGoBack = 12 * 7
    start.setDate(start.getDate() - numberOfDaysToGoBack)
    while start < currentDay
      dateString = start.getMonth() + 1 + "/" + start.getDate() + "/" + start.getFullYear()
      newDate = start.setDate(start.getDate() + 7)
      start = new Date(newDate)

      receivedOnThisWeek = 0
      if dateString of receivedEmailsPerWeek
        receivedOnThisWeek = receivedEmailsPerWeek[dateString]
      sentOnThisWeek = 0
      if dateString of sentEmailsPerWeek
        sentOnThisWeek = sentEmailsPerWeek[dateString]

      dataOutput.push([dateString, receivedOnThisWeek, sentOnThisWeek])
    return dataOutput

  prepareMonthlyEmailVolumeDataOutput: (model) ->
    receivedEmailsPerMonth = model.get("received_emails_per_month")
    sentEmailsPerMonth = model.get("sent_emails_per_month")
    dataOutput = []
    dataOutput.push(['Month', 'Received', 'Sent'])
    stopDate = new Date(Date.now())
    stopDate.setMonth(stopDate.getMonth() + 1)
    start = new Date(Date.now())
    start.setDate(start.getDate() - 356)
    while start < stopDate
      dateString = start.getMonth() + 1 + "/1/" + start.getFullYear()
      newDate = start.setMonth(start.getMonth() + 1)
      start = new Date(newDate)

      receivedOnThisMonth = 0
      if dateString of receivedEmailsPerMonth
        receivedOnThisMonth = receivedEmailsPerMonth[dateString]
      sentOnThisMonth = 0
      if dateString of sentEmailsPerMonth
        sentOnThisMonth = sentEmailsPerMonth[dateString]

      dataOutput.push([dateString, receivedOnThisMonth, sentOnThisMonth])
    return dataOutput

  showEmailVolumeReport: ->
    emailVolumeReport = new TuringEmailApp.Models.EmailVolumeReport()
    emailVolumeReport.fetch(
      success: (model, response, options) =>

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
    topSendersAndRecipientsReport.fetch(
      success: (model, response, options) =>
        incomingEmailData = { 
          people : [],
          title : "Incoming Email Volume Chart"
        }
        for recipientAddress, count of model.get("top_recipients")
          incomingEmailData.people.push([recipientAddress, count])
        console.log incomingEmailData
        model.set "incomingEmailData", incomingEmailData

        outgoingEmailData = { 
          people : [],
          title : "Outgoing Email Volume Chart"
        }
        for senderAddress, count of model.get("top_senders")
          outgoingEmailData.people.push([senderAddress, count])
        console.log outgoingEmailData
        model.set "outgoingEmailData", outgoingEmailData

        topSendersAndRecipientsReportView = new TuringEmailApp.Views.Reports.TopSendersAndRecipientsReportView(
          model: topSendersAndRecipientsReport
          el: $("#reports")
        )
        topSendersAndRecipientsReportView.render()
    )

  showWordCountReport: ->
    wordCountReport = new TuringEmailApp.Models.WordCountReport()
    @.loadWordCountReportSampleData wordCountReport
    wordCountReportView = new TuringEmailApp.Views.Reports.WordCountReportView(
      model: wordCountReport
      el: $("#reports")
    )
    wordCountReportView.render()
