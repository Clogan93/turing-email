class TuringEmailApp.Routers.InboxCleanerRouter extends Backbone.Router
  routes:
    "inbox_cleaner": "showInboxCleaner"

  showInboxCleaner: ->
    TuringEmailApp.showInboxCleaner()
