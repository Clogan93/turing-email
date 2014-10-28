class TuringEmailApp.Routers.SettingsRouter extends Backbone.Router
  routes:
    "settings": "showSettings"
    
  showSettings: ->
    TuringEmailApp.showSettings()
