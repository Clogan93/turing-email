TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.WebsitePreviewView extends TuringEmailApp.Views.App.ComposeView
  template: JST["backbone/templates/app/compose/website_preview"]

  render: ->
    @$el.html(@template(@model.toJSON()))

    return this

  hide: ->
    return
    # @$el.find("#compose_form").hide()
