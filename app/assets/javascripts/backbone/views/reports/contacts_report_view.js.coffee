TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.ContactsReportView extends Backbone.View
  template: JST["backbone/templates/reports/contacts_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    googleChartData = @getGoogleChartData()

    @$el.html(@template(googleChartData))

    @renderGoogleChart googleChartData

    return this

  getGoogleChartData: ->
    topSenders = @model.get("top_senders")
    topRecipients = @model.get("top_recipients")
    
    data =
      topSenders: [["Person", "Percent"]].concat(
        _.zip(_.keys(topSenders), _.values(topSenders))
      )
      topRecipients: [["Person", "Percent"]].concat(
        _.zip(_.keys(topRecipients), _.values(topRecipients))
      )

    return data

  renderGoogleChart: (googleChartData) ->
    google.load('visualization', '1.0',
                 callback: => @drawCharts(googleChartData)
                 packages: ["corechart"])

  drawCharts: (googleChartData) ->
    @drawEmailVolumeChart googleChartData.topSenders, "top_senders", "Incoming Emails"
    @drawEmailVolumeChart googleChartData.topRecipients, "top_recipients", "Outgoing Emails"

  drawEmailVolumeChart: (data, divID, chartTitle) ->
    options =
      title: chartTitle
      width: 500
      height: 300

    chart = new google.visualization.PieChart($("#" + divID)[0])
    dataTable = google.visualization.arrayToDataTable(data)
    chart.draw dataTable, options
