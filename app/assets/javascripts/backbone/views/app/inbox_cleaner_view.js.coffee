TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.InboxCleanerView extends Backbone.View
  template: JST["backbone/templates/app/inbox_cleaner"]

  className: "inbox-cleaner"

  initialize: ->
    if @model
      @listenTo(@model, "change", @render)
      @listenTo(@model, "destroy", @remove)
  
  render: ->
    @$el.empty()

    @$el.html(@template(@model.toJSON())) if _.keys(@model.attributes).length > 0
    
    return this
