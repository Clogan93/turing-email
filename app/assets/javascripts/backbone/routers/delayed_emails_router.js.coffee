class TuringEmailApp.Routers.DelayedEmailsRouter extends Backbone.Router
  routes:
    "delayed_emails": "showDelayedEmails"

  showDelayedEmails: ->
    TuringEmailApp.showDelayedEmails()
