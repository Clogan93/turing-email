TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.AttachmentsReportView extends Backbone.View
  template: JST["backbone/templates/reports/attachments_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  render: ->
    TuringEmailApp.showReport()
    @$el.html(@template(@model.toJSON()))
    return this
