TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListItemView extends Backbone.View
  template: JST["backbone/templates/email_threads/list_item"]
  tagName: "tr"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  render: ->
    if @model.get("emails")[0].seen
      @$el.addClass("read")
    else
      @$el.addClass("unread")

    @$el.css({ cursor: "pointer" });
    @$el.html(@template(@model.toJSON()))

    return this
