TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.EmbeddedComposeView extends TuringEmailApp.Views.App.ComposeView
  template: JST["backbone/templates/app/compose/compose_form"]

  render: ->
    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft(@email)

    @$el.html(@template({ email: @email, userAddress: @app.models.user.get("email") }))
    @postRenderSetup()

    return this

  hide: ->
    @$el.find("#compose-form").hide()
