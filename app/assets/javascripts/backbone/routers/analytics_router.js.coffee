class TuringEmailApp.Routers.AnalyticsRouter extends Backbone.Router
  routes:
    "analytics": "showAnalytics"
    
  showAnalytics: ->
    analyticsView = new TuringEmailApp.Views.AnalyticsView(
      el: $("#reports")
    )
  
    analyticsView.render()
