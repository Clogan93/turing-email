TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.ListSubscriptionsView extends TuringEmailApp.Views.CollectionView
  template: JST["backbone/templates/app/list_subscriptions"]
  
  render: ->
    @$el.html(@template(listSubscriptions: @collection.toJSON()))

    @setupButtons()

    return this

  setupButtons: ->
    @$el.find(".unsubscribe-list-button").click (event) =>
      @onUnsubscribeListClick(event)

  onUnsubscribeListClick: (event) ->
    index = @$el.find(".unsubscribe-list-button").index(event.currentTarget)
    listSubscription = @collection.at(index)

    @trigger("unsubscribeListClicked", this, listSubscription)

    return false
