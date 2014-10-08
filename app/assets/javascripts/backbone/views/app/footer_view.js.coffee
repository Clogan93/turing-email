TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.FooterView extends Backbone.View
  template: JST["backbone/templates/app/footer"]

  render: ->
    @$el.html(@template())
    return this
