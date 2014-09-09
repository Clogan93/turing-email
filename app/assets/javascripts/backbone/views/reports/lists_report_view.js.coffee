TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.ListsReportView extends Backbone.View
  template: JST["backbone/templates/reports/lists_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    TuringEmailApp.reportsRouter.restyle_other_elements()

    console.log @model.toJSON()
    @$el.html(@template(@model.toJSON()))
    return this
