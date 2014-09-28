TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.GeoReportView extends Backbone.View
  template: JST["backbone/templates/reports/geo_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "removedFromCollection destroy", @remove)

  render: ->
    googleChartData = @getGoogleChartData()

    @$el.html(@template(googleChartData))

    TuringEmailApp.showReports()
    return this

  getGoogleChartData: ->
    ipStats = @model.get("ip_stats")

    cityStats = {}
    
    for ipStat in ipStats
      cityStats[ipStat.ip_info.city] ?= 0
      cityStats[ipStat.ip_info.city] += ipStat.num_emails
    
    data =
      cityStats: [["City", "Number of Emails"]].concat(
        _.zip(_.keys(cityStats), _.values(cityStats))
      )

    return data
