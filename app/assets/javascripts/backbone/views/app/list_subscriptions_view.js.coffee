TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.ListSubscriptionsView extends TuringEmailApp.Views.CollectionView
  template: JST["backbone/templates/app/list_subscriptions"]

  className: "list-subscriptions"

  render: ->
    selectedTabID = $(".tab-pane.active").attr("id")
    
    @listsSubscribed = []
    @listsUnsubscribed = []

    listsSubscribedJSON = []
    listsUnsubscribedJSON = []

    for listSubscription in @collection.models
      if listSubscription.get("unsubscribed")
        @listsUnsubscribed.push(listSubscription)
        listsUnsubscribedJSON.push(listSubscription.toJSON())
      else
        @listsSubscribed.push(listSubscription)
        listsSubscribedJSON.push(listSubscription.toJSON())

    params =
      listsSubscribed: listsSubscribedJSON
      listsUnsubscribed: listsUnsubscribedJSON

    @$el.html(@template(params))

    @setupButtons()

    $("a[href=#" + selectedTabID + "]").click() if selectedTabID?

    return this

  setupButtons: ->
    @$el.find(".unsubscribe-list-button").click (event) =>
      @onUnsubscribeListClick(event)
      
    @$el.find(".resubscribe-list-button").click (event) =>
      @onResubscribeListClick(event)

  onUnsubscribeListClick: (event) ->
    index = @$el.find(".unsubscribe-list-button").index(event.currentTarget)
    listSubscription = @listsSubscribed[index]

    @trigger("unsubscribeListClicked", this, listSubscription)

    return false

  onResubscribeListClick: (event) ->
    index = @$el.find(".resubscribe-list-button").index(event.currentTarget)
    listSubscription = @listsUnsubscribed[index]

    @trigger("resubscribeListClicked", this, listSubscription)

    return false
