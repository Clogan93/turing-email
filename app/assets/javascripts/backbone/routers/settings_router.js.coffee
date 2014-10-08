class TuringEmailApp.Routers.SettingsRouter extends Backbone.Router
  routes:
    "settings": "showSettings"
    
  showSettings: ->
    if not TuringEmailApp.models.userSettings?
      TuringEmailApp.models.userSettings = new TuringEmailApp.Models.UserSettings()
      TuringEmailApp.models.userSettings.fetch(
        success: (model, response, options) =>
          TuringEmailApp.showSettings()
      )
    else
      TuringEmailApp.showSettings()
