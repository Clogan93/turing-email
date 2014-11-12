class TuringEmailApp.Routers.EmailTrackersRouter extends Backbone.Router
  routes:
    "email_trackers": "showEmailTrackers"

  showEmailTrackers: ->
    TuringEmailApp.showEmailTrackers()
