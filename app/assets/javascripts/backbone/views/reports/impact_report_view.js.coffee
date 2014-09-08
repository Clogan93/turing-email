TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.ImpactReportView extends Backbone.View
  template: JST["backbone/templates/reports/impact_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    TuringEmailApp.reportsRouter.restyle_other_elements()

    @$el.html(@template(@model.toJSON()))
    return this
