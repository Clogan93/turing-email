TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListItemView extends Backbone.View
  template: JST["backbone/templates/email_threads/list_item"]
  tagName: "tr"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy hide", @remove)

  render: ->
    if TuringEmailApp.user.get("email") == @model.get("emails")[0].from_address
      @model.attributes.emails[0].from_name = "me"

    @$el.html @template(@model.toJSON())

    return this

  remove: ->
    @$el.remove()
