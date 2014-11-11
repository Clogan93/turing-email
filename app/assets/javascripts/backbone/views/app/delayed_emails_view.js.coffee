TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.DelayedEmailsView extends Backbone.View
  template: JST["backbone/templates/app/delayed_emails"]
  
  initialize: (options) ->
    @listenTo(@collection, "add", => @render())
    @listenTo(@collection, "remove", => @render())
    @listenTo(@collection, "reset", => @render())
    @listenTo(@collection, "destroy", => @render())

  render: ->
    @$el.html(@template(delayed_emails: @collection.toJSON()))

    @setupButtons()
    
    return this

  setupButtons: ->
    @$el.find(".delete-delayed-email-button").click (event) =>
      @onDeleteDelayedEmailClick(event)

  onDeleteDelayedEmailClick: (event) ->
    index = @$el.find(".delete-delayed-email-button").index(event.currentTarget)
    delayedEmail = @collection.at(index)

    @trigger("deleteDelayedEmailClicked", this, delayedEmail.get("uid"))

    return false
