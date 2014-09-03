TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.EmailVolumeReportView extends Backbone.View
  template: JST["backbone/templates/reports/email_volume_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    @$el.html(@template(@model.toJSON()))
    return this
