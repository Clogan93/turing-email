class TuringEmailApp.Routers.SettingsRouter extends Backbone.Router
  routes:
    "settings": "showSettings"
    
  showSettings: ->
    if TuringEmailApp.userSettings?
      TuringEmailApp.userSettings = new TuringEmailApp.Models.UserSettings()
      TuringEmailApp.userSettings.fetch(
        success: (model, response, options) =>
          @renderSettingsView()
      )
    else
      @renderSettingsView()

  renderSettingsView: ->
    settingsView = new TuringEmailApp.Views.SettingsView(
      model: TuringEmailApp.userSettings
      el: $("#settings")
    )
  
    settingsView.render()
