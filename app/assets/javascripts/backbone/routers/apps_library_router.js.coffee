class TuringEmailApp.Routers.AppsLibraryRouter extends Backbone.Router
  routes:
    "apps": "showAppsLibrary"

  showAppsLibrary: ->
    TuringEmailApp.showAppsLibrary()
