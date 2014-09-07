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

  ##################################################################
  ######################## Data Preparation ########################
  ##################################################################

  translateContentType: (attachmentdata, header) ->
    newAttachmentsData = {}
    newAttachmentsData["Document"] = 0
    for attachmentData in attachmentdata
      contentTypeParts = attachmentData[0].split("/")
      value = attachmentData[1]
      if contentTypeParts[0] is "image"
        if newAttachmentsData["Images"]?
          newAttachmentsData["Images"] += value
        else 
          newAttachmentsData["Images"] = value
      else
        lastIndex = parseInt(contentTypeParts.length) - 1
        contentType = contentTypeParts[lastIndex]
        switch contentType
          when "ics" then newAttachmentsData["Calendar Invite"] = value
          when "pdf" then newAttachmentsData["PDF"] = value
          when "vnd.openxmlformats-officedocument.presentationml.presentation" then newAttachmentsData["Presentation"] = value
          when "vnd.openxmlformats-officedocument.spreadsheetml.sheet" then newAttachmentsData["Spreadsheet"] = value
          when "msword" then newAttachmentsData["Document"] += value
          when "vnd.openxmlformats-officedocument.wordprocessingml.document" then newAttachmentsData["Document"] += value
          when "zip" then newAttachmentsData["ZIP"] = value
          when "octet-stream" then newAttachmentsData["Binary"] = value
          else newAttachmentsData[contentType] = value
    attachmentdata = []
    attachmentdata.push(header)
    for key, value of newAttachmentsData
      attachmentdata.push([key, value])
    return attachmentdata

  prepareEmailVolumeDataOutput: (receivedEmails, sentEmails, timePeriodLabel, startDate, stopDate, timeJump, isMonthRelevant) ->
    dataOutput = []
    dataOutput.push([timePeriodLabel, 'Received', 'Sent'])
    while startDate < stopDate
      if isMonthRelevant is yes
        month_text = startDate.getDate()
      else
        month_text = "/1/"
      dateString = startDate.getMonth() + 1 + "/" + month_text + "/" + startDate.getFullYear()
      newDate = startDate.setDate(startDate.getDate() + timeJump)
      startDate = new Date(newDate)
      receivedOnThisDay = 0
      if dateString of receivedEmails
        receivedOnThisDay = receivedEmails[dateString]
      sentOnThisDay = 0
      if dateString of sentEmails
        sentOnThisDay = sentEmails[dateString]
      dataOutput.push([dateString, receivedOnThisDay, sentOnThisDay])
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

  ##################################################################
  ########################## Show Reports ##########################
  ##################################################################

  showAttachmentsReport: ->
    attachmentsReport = new TuringEmailApp.Models.AttachmentsReport()
    attachmentsReport.fetch(
      success: (model, response, options) =>
        data = { 
          numAttachmentsData : []
          averageFileSizeAttachmentsData : []
        }

        for contentType, stats of model.get("content_type_stats")
          data.numAttachmentsData.push([contentType, stats.num_attachments])
          data.averageFileSizeAttachmentsData.push([contentType, stats.average_file_size])

        data.numAttachmentsData = @translateContentType data.numAttachmentsData, ['Attachment Type', 'Number of attachments']
        data.averageFileSizeAttachmentsData = @translateContentType data.averageFileSizeAttachmentsData, ['Attachment Type', 'Average File Size']

        attachmentsReport.set "data", data

        attachmentsReportView = new TuringEmailApp.Views.Reports.AttachmentsReportView(
          model: model
          el: $("#reports")
        )
        attachmentsReportView.render()
    )

  showEmailVolumeReport: ->
    emailVolumeReport = new TuringEmailApp.Models.EmailVolumeReport()
    emailVolumeReport.fetch(
      success: (model, response, options) =>

        dailyStartDate = new Date(Date.now())
        dailyStartDate.setDate(dailyStartDate.getDate() - 30)
        dailyStopDate = new Date(Date.now())
        dailyEmailVolumeData = { 
          data : @prepareEmailVolumeDataOutput model.get("received_emails_per_day"), model.get("sent_emails_per_day"), 'Day', dailyStartDate, dailyStopDate, 1, yes
        }
        model.set "dailyEmailVolumeData", dailyEmailVolumeData

        weeklyStartDate = new Date(Date.now())
        weeklyStartDate.setDate(weeklyStartDate.getDate() - weeklyStartDate.getDay() + 1)
        numberOfDaysToGoBack = 12 * 7
        weeklyStartDate.setDate(weeklyStartDate.getDate() - numberOfDaysToGoBack)
        weeklyStopDate = new Date(Date.now())
        weeklyEmailVolumeData = { 
          data : @prepareEmailVolumeDataOutput model.get("received_emails_per_week"), model.get("sent_emails_per_week"), 'Week', weeklyStartDate, weeklyStopDate, 7, yes
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
        model.set "incomingEmailData", incomingEmailData
        outgoingEmailData = { 
          people : [],
          title : "Outgoing Email Volume Chart"
        }
        for senderAddress, count of model.get("top_senders")
          outgoingEmailData.people.push([senderAddress, count])
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
