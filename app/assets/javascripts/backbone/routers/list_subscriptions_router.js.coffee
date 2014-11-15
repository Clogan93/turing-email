class TuringEmailApp.Routers.ListSubscriptionsRouter extends Backbone.Router
  routes:
    "list_subscriptions": "showListSubscriptions"

  showListSubscriptions: ->
    TuringEmailApp.showListSubscriptions()
