TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.WordCountReportView extends Backbone.View
  template: JST["backbone/templates/reports/word_count_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    TuringEmailApp.reportsRouter.restyle_other_elements()

    @$el.html(@template(@model.toJSON()))
    return this
