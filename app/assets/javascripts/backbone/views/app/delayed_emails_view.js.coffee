TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.DelayedEmailsView extends TuringEmailApp.Views.CollectionView
  template: JST["backbone/templates/app/delayed_emails"]

  className: "delayed-emails"

  render: ->
    @$el.html(@template(delayedEmails: @collection.toJSON()))

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
