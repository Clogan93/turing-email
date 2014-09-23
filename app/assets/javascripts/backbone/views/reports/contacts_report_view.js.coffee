TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.ContactsReportView extends Backbone.View
  template: JST["backbone/templates/reports/contacts_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    TuringEmailApp.showReport()
    @$el.html(@template(@model.toJSON()))
    return this
