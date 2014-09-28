TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.ThreadsReportView extends Backbone.View
  template: JST["backbone/templates/reports/threads_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "removedFromCollection destroy", @remove)

  render: ->
    @$el.html(@template(@model.toJSON()))
    TuringEmailApp.showReports()
    return this
