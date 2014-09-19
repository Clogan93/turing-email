class TuringEmailApp.Models.EmailVolumeReport extends Backbone.Model
  url: "/api/v1/email_reports/volume_report"

  parse: (response, options) ->
    parsedResponse = {}

    dailyStartDate = new Date(Date.now())
    dailyStartDate.setDate(dailyStartDate.getDate() - 30)
    
    dailyStopDate = new Date(Date.now())
    dailyEmailVolumeData = { 
      data : @prepareEmailVolumeDataOutput response["received_emails_per_day"],
                                           response["sent_emails_per_day"], 'Day',
                                           dailyStartDate, dailyStopDate, 1, yes
    }
    
    parsedResponse["dailyEmailVolumeData"] = dailyEmailVolumeData

    weeklyStartDate = new Date(Date.now())
    weeklyStartDate.setDate(weeklyStartDate.getDate() - weeklyStartDate.getDay() + 1)
    numberOfDaysToGoBack = 12 * 7
    weeklyStartDate.setDate(weeklyStartDate.getDate() - numberOfDaysToGoBack)
    weeklyStopDate = new Date(Date.now())
    
    weeklyEmailVolumeData = { 
      data : @prepareEmailVolumeDataOutput response["received_emails_per_week"],
                                           response["sent_emails_per_week"], 'Week',
                                           weeklyStartDate, weeklyStopDate, 7, yes
    }
    parsedResponse["weeklyEmailVolumeData"] = weeklyEmailVolumeData

    monthlyEmailVolumeData = { 
      data : @prepareMonthlyEmailVolumeDataOutput(response)
    }
    parsedResponse["monthlyEmailVolumeData"] = monthlyEmailVolumeData

    return parsedResponse

  prepareEmailVolumeDataOutput: (receivedEmails, sentEmails,
                                 timePeriodLabel, startDate, stopDate,
                                 timeJump, isMonthRelevant) ->
    dataOutput = []
    dataOutput.push([timePeriodLabel, 'Received', 'Sent'])
    
    while startDate < stopDate
      if isMonthRelevant is yes
        day_text = startDate.getDate()
      else
        month_text = "/1/"

      dateString = startDate.getMonth() + 1 + "/" + day_text + "/" + startDate.getFullYear()
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

  prepareMonthlyEmailVolumeDataOutput: (response) ->
    receivedEmailsPerMonth = response["received_emails_per_month"]
    sentEmailsPerMonth = response["sent_emails_per_month"]
    
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

  received_emails_per_day:
    required: true

  received_emails_per_month:
    required: true

  received_emails_per_week:
    required: true

  sent_emails_per_day:
    required: true

  sent_emails_per_month:
    required: true

  sent_emails_per_week:
    required: true
