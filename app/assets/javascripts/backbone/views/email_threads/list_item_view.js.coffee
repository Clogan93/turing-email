TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListItemView extends Backbone.View
  template: JST["backbone/templates/email_threads/list_item"]
  tagName: "TR"

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
    
    @$el.data({
      isDraft: @model.get("emails")[0].draft_id?
      emailThreadUID: @model.get("uid")
    })
    
    @$el.attr("name", @model.get("uid"))

    return this
