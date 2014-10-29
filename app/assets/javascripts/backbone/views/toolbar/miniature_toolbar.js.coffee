class TuringEmailApp.Views.MiniatureToolbarView extends Backbone.View
  template: JST["backbone/templates/toolbar/miniature_toolbar"]
  tagName: "div"
  className: "row"

  initialize: (options) ->
    @app = options.app

    @$el.addClass("miniature-toolbar")

  render: ->
    @$el.html(@template())
    
    @renderReportToolbarDropdown()

    @setupSettingsButton()

    return this

  #################
  ### Functions ###
  #################

  renderReportToolbarDropdown: ->
    @reportToolbarDropdown = new TuringEmailApp.Views.ReportToolbarDropdownView(
      el: @$el.find(".report_toolbar_dropdown")
    )
    @reportToolbarDropdown.render()

  setupSettingsButton: ->
    @$el.find(".settings-button").click ->
      $(this).tooltip('hide')
