TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.EmailVolumeReportView extends Backbone.View
  template: JST["backbone/templates/reports/email_volume_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    googleChartData = @getGoogleChartData()

    @$el.html(@template(googleChartData))

    @renderGoogleChart googleChartData

    return this

  getGoogleChartData: ->
    dailyEmailData = @getDailyEmailData(@model.get("received_emails_per_day"), @model.get("sent_emails_per_day"))
    weeklyEmailData = @getWeeklyEmailData(@model.get("received_emails_per_week"), @model.get("sent_emails_per_week"))
    monthlyEmailData = @getEmailVolumeDataPerMonth(@model.get("received_emails_per_month"),
                                                   @model.get("sent_emails_per_month"))

    data =
      emailsPerDayGChartData: [["Day", "Received", "Sent"]].concat(dailyEmailData)
      emailsPerWeekGChartData: [["Week", "Received", "Sent"]].concat(weeklyEmailData)
      emailsPerMonthGChartData: [["Month", "Received", "Sent"]].concat(monthlyEmailData)

    return data
  
  getDailyEmailData: (receivedEmailsPerDay, sentEmailsPerDay) ->
    startDate = new Date(Date.now())
    startDate.setDate(startDate.getDate() - 30) # go back one month
  
    stopDate = new Date(Date.now())

    @getEmailVolumeDataPerDay(receivedEmailsPerDay, sentEmailsPerDay,
                              "Day", startDate, stopDate, 1)

  getWeeklyEmailData: (receivedEmailsPerWeek, sentEmailsPerWeek) ->
    startDate = new Date(Date.now())
    startDate.setDate(startDate.getDate() - startDate.getDay() + 1) # go to start of week
    startDate.setDate(startDate.getDate() - 11 * 7) # go back 11 weeks
    
    stopDate = new Date(Date.now())

    @getEmailVolumeDataPerDay(receivedEmailsPerWeek, sentEmailsPerWeek,
                              "Week", startDate, stopDate, 7)
    
  getEmailVolumeDataPerDay: (receivedEmails, sentEmails,
                             timePeriodLabel, startDate, stopDate, numDaysDelta) ->
    data = []

    currentDate = startDate
    while currentDate <= stopDate
      dateString = currentDate.getMonth() + 1 + "/" + currentDate.getDate() + "/" + currentDate.getFullYear()
      
      receivedOnThisDay = receivedEmails[dateString] ? 0
      sentOnThisDay = sentEmails[dateString] ? 0
      
      data.push([dateString, receivedOnThisDay, sentOnThisDay])

      currentDate.setDate(currentDate.getDate() + numDaysDelta)

    return data

  getEmailVolumeDataPerMonth: (receivedEmails, sentEmails) ->
    data = []

    startDate = new Date(Date.now())
    startDate.setMonth(startDate.getMonth() - 11)
    
    stopDate = new Date(Date.now())

    currentDate = startDate
    while currentDate <= stopDate
      dateString = currentDate.getMonth() + 1 + "/1/" + currentDate.getFullYear()
      
      receivedOnThisMonth = receivedEmails[dateString] ? 0
      sentOnThisMonth = sentEmails[dateString] ? 0

      data.push([dateString, receivedOnThisMonth, sentOnThisMonth])

      currentDate.setMonth(currentDate.getMonth() + 1)

    return data

  renderGoogleChart: (googleChartData) ->
    google.load('visualization', '1.0',
                 callback: => @drawCharts(googleChartData)
                 packages: ["corechart"])

  drawCharts: (googleChartData) ->
    @drawChart googleChartData.emailsPerDayGChartData, ".emails_per_day_chart_div", "Daily Email Volume"
    @drawChart googleChartData.emailsPerWeekGChartData, ".emails_per_week_chart_div", "Weekly Email Volume"
    @drawChart googleChartData.emailsPerMonthGChartData, ".emails_per_month_chart_div", "Monthly Email Volume"

  drawChart: (data, divSelector, chartTitle) ->
    return if $(divSelector).length is 0
    
    options =
      title: chartTitle
      hAxis:
        titleTextStyle:
          color: "#333"

      vAxis:
        minValue: 0

    chart = new google.visualization.AreaChart($(divSelector)[0])
    dataTable = google.visualization.arrayToDataTable(data)
    chart.draw dataTable, options
