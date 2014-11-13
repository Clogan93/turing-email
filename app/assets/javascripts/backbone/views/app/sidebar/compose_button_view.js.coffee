TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.ComposeButtonView extends Backbone.View
  template: JST["backbone/templates/app/sidebar/compose_button"]

  render: ->
    @$el.prepend(@template())

    return this
