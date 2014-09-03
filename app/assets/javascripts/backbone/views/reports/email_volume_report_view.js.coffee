TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.EmailVolumeReportView extends Backbone.View
  template: JST["backbone/templates/reports/email_volume_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    #Re-styling of other elements
    $("#inbox-page-header").hide()
    $("#pages").hide()
    $("#email_table").hide()
    $("#preview_pane").hide()
    $(".main_email_list_content").css("height", "100%");

    @$el.html(@template(@model.toJSON()))
    return this
