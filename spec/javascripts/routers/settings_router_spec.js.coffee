describe "SettingsRouter", ->

  beforeEach ->
    @router = new TuringEmailApp.Routers.SettingsRouter()
    TuringEmailApp.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
    @routeSpy = sinon.spy()
    try
      Backbone.history.start
        silent: true

  it "has a settings route and points to the showSettings method", ->
    expect(@router.routes["settings"]).toEqual "showSettings"

  it "fires the showSettings route with settings", ->
    @router.bind "route:showSettings", @routeSpy
    @router.navigate "settings",
      trigger: true
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith()
    return
