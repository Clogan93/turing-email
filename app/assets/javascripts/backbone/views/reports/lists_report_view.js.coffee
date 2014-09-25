TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.ListsReportView extends Backbone.View
  template: JST["backbone/templates/reports/lists_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  render: ->
    TuringEmailApp.showReports()
    @$el.html(@template(@model.toJSON()))
    return this
