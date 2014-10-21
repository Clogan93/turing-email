class TuringEmailApp.Views.ReportToolbarDropdown extends Backbone.View
  template: JST["backbone/templates/toolbar/report_toolbar_dropdown"]

  render: ->
    @$el.html(@template())

    return this
