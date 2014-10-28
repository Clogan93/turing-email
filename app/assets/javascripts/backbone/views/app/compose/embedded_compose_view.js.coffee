TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.EmbeddedComposeView extends TuringEmailApp.Views.App.ComposeView
  template: JST["backbone/templates/app/compose/embedded_compose"]

  render: ->
    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft(@email)

    @$el.html(@template({ email: @email }))

    @setupComposeView()

    return this

  hide: ->
    @$el.find("#compose-form").hide()
