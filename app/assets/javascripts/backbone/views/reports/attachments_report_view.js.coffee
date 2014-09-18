TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.AttachmentsReportView extends Backbone.View
  template: JST["backbone/templates/reports/attachments_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    console.log "RENDER!!!!!!!"
    TuringEmailApp.reportsRouter.restyle_other_elements()

    @$el.html(@template(@model.toJSON()))

    console.log "Returning render"
    console.log @model.toJSON()

    return this
