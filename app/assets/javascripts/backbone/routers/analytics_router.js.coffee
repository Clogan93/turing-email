class TuringEmailApp.Routers.AnalyticsRouter extends Backbone.Router
  routes:
    "analytics": "showAnalytics"
    
  showAnalytics: ->
    analyticsView = new TuringEmailApp.Views.Reports.AnalyticsView(
      el: $("#reports")
    )
  
    analyticsView.render()
