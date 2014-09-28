TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.SummaryAnalyticsReportView extends Backbone.View
  template: JST["backbone/templates/reports/summary_analytics_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "removedFromCollection destroy", @remove)

  render: ->
    TuringEmailApp.showReports()
    @$el.html(@template(@model.toJSON()))
    return this
