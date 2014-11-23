class TuringEmailApp.Routers.TourRouter extends Backbone.Router
  routes:
    "welcome_tour": "showWelcomeTour"
    
  showWelcomeTour: ->
    TuringEmailApp.showWelcomeTour()
