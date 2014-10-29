TuringEmailApp.Models.InstalledApps ||= {}

class TuringEmailApp.Models.InstalledApps.InstalledApp extends Backbone.Model
  @CreateFromJSON: (installedAppJSON) ->
    if installedAppJSON.installed_app_subclass_type == "InstalledPanelApp"
      return new TuringEmailApp.Models.InstalledApps.InstalledPanelApp(installedAppJSON)
    
    return null
