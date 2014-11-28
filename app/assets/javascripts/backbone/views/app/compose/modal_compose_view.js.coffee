TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.ModalComposeView extends TuringEmailApp.Views.App.ComposeView

  render: ->
    super()
    @setupCustomComposeToolbarButtons()
