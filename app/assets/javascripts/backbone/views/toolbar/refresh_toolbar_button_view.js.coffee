class TuringEmailApp.Views.RefreshToolbarButtonView extends Backbone.View
  template: JST["backbone/templates/toolbar/refresh_toolbar_button"]

  render: ->
    @$el.html(@template())

    return this

  show: ->
    @$el.show()

  hide: ->
    @$el.hide()
