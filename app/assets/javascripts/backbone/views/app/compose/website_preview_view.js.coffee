TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.WebsitePreviewView extends Backbone.View
  template: JST["backbone/templates/app/compose/website_preview"]

  initialize: ->
    @listenTo(@model, "change", @render)

  render: ->
    @$el.append(@template(@model.toJSON()))

    @$el.find(".compose_link_preview_close_button").click =>
      @hide()

    return this

  hide: ->
    @$el.find(".compose_link_preview").remove()
