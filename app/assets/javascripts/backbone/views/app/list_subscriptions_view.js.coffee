TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.ListSubscriptionsView extends TuringEmailApp.Views.CollectionView
  template: JST["backbone/templates/app/list_subscriptions"]

  className: "list-subscriptions"

  initialize: (options) ->
    super(options)
    @currentListsSubscribedPageNumber = 0
    @currentListsUnsubscribedPageNumber = 0
    @pageSize = 25

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
      currentListsSubscribedPageNumber: @currentListsSubscribedPageNumber
      currentListsUnsubscribedPageNumber: @currentListsUnsubscribedPageNumber
      pageSize: @pageSize

    @$el.html(@template(params))

    @setupButtons()

    @setupListPagination()

    $("a[href=#" + selectedTabID + "]").click() if selectedTabID?

    return this

  setupButtons: ->
    @$el.find(".unsubscribe-list-button").click (event) =>
      @onUnsubscribeListClick(event)

    @$el.find(".resubscribe-list-button").click (event) =>
      @onResubscribeListClick(event)

  #TODO write tests, or replace with infinite scroll and then write tests.
  setupListPagination: ->
    @$el.find(".list-subscription-pagination .next-list-subscription-page").click (event) =>
      if @listsSubscribed.length >= ((@currentListsSubscribedPageNumber + 1) * @pageSize)
        @currentListsSubscribedPageNumber += 1
        @render()
      false

    @$el.find(".list-subscription-pagination .previous-list-subscription-page").click (event) =>
      if @currentListsSubscribedPageNumber > 0
        @currentListsSubscribedPageNumber -= 1
        @render()
      false

    @$el.find(".list-unsubscription-pagination .next-list-unsubscription-page").click (event) =>
      if @listsUnsubscribed.length >= ((@currentListsUnsubscribedPageNumber + 1) * @pageSize)
        @currentListsUnsubscribedPageNumber += 1
        @render()
      false

    @$el.find(".list-unsubscription-pagination .previous-list-unsubscription-page").click (event) =>
      if @currentListsUnsubscribedPageNumber > 0
        @currentListsUnsubscribedPageNumber -= 1
        @render()
      false

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
