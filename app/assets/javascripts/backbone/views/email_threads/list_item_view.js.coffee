TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListItemView extends Backbone.View
  template: JST["backbone/templates/email_threads/list_item"]
  tagName: "tr"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    if TuringEmailApp.user.get("email") == @model.get("emails")[0].from_address
      @model.attributes.emails[0].from_name = "me"

    if @model.get("emails")[0].seen
        @$el.addClass("read")
    else
      @$el.addClass("unread")

    @$el.html(@template(@model.toJSON()))

    return this
