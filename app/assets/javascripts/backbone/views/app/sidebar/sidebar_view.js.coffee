TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.SidebarView extends Backbone.View
  template: JST["backbone/templates/app/sidebar/sidebar"]

  render: ->
    @$el.html(@template())

    @composebuttonview = new TuringEmailApp.Views.App.ComposeButtonView(
      el: @$el.find(".file-manager")
    )
    @composebuttonview.render()

    return this
