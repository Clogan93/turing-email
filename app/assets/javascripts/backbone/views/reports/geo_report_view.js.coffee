TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.GeoReportView extends Backbone.View
  template: JST["backbone/templates/reports/geo_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  #TODO: consolidate into a single function for views.
  #TODO: re-factor mail.html.erb so that this is not longer necessary.
  restyle_other_elements: ->
    $(".mail-box-header").hide()
    $("table.table-mail").hide()
    $("#pages").hide()
    $("#email_table").hide()
    $("#preview_pane").hide()
    $(".main_email_list_content").css("height", "100%");

  render: ->
    this.restyle_other_elements()

    @$el.html(@template(@model.get("data")))
    return this
