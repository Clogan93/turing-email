TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.FoldersReportView extends Backbone.View
  template: JST["backbone/templates/reports/folders_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    @$el.html(@template(@model.toJSON()))
    return this
