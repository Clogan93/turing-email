class TuringEmailApp.Models.ListSubscription extends Backbone.Model
  @Unsubscribe: (listSubscription) ->
    $.ajax
      url: "/api/v1/list_subscriptions/unsubscribe"
      type: "DELETE"
      data: listSubscription.toJSON()
