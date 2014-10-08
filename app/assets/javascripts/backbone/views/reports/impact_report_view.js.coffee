TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.ImpactReportView extends Backbone.View
  template: JST["backbone/templates/reports/impact_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    @$el.html(@template(@model.toJSON()))
    return this
