class TuringEmailApp.Routers.AnalyticsRouter extends Backbone.Router
  routes:
    "analytics": "showAnalytics"
    
  showAnalytics: ->
    TuringEmailApp.showAnalytics()
