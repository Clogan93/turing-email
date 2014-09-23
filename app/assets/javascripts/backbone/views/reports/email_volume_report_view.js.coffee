TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.EmailVolumeReportView extends Backbone.View
  template: JST["backbone/templates/reports/email_volume_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  render: ->
    TuringEmailApp.showReport()
    @$el.html(@template(@model.toJSON()))
    return this
