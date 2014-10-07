TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.SidebarView extends Backbone.View
  template: JST["backbone/templates/app/sidebar"]

  render: ->
    @$el.html(@template())
    return this
