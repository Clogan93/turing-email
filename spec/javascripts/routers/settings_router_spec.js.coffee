describe "SettingsRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    userSettingsFixtures = fixture.load("user_settings.fixture.json");
    @validUserSettingsFixture = userSettingsFixtures[0]["valid"]

    @settingsRouter = new TuringEmailApp.Routers.SettingsRouter()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/user_configurations"
    @server.respondWith "GET", @url, JSON.stringify(@validUserSettingsFixture)

    TuringEmailApp.models.userSettings.fetch()
    @server.respond()

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@settingsRouter.routes["settings"]).toEqual "showSettings"

  describe "settings", ->
    beforeEach ->
      @showSettingsSpy = sinon.spy(TuringEmailApp, "showSettings")
      @settingsRouter.navigate "settings", trigger: true

    afterEach ->
      @showSettingsSpy.restore()

    it "shows the settings", ->
      expect(@showSettingsSpy).toHaveBeenCalled()
