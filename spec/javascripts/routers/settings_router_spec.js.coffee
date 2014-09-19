describe "SettingsRouter", ->

  beforeEach ->
    @router = new TuringEmailApp.Routers.SettingsRouter()
    @routeSpy = sinon.spy()
    try
      TuringEmailApp.start()

  it "has a settings route and points to the showSettings method", ->
    expect(@router.routes["settings"]).toEqual "showSettings"
