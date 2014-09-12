class TuringEmailApp.Routers.SettingsRouter extends Backbone.Router
  routes:
    "settings": "showSettings"
    
  showSettings: ->
    settingsView = new TuringEmailApp.Views.Reports.SettingsView(
      el: $("#reports")
    )
  
    settingsView.render()
