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

  it "has the expected routes", ->
    expect(@settingsRouter.routes["settings"]).toEqual "showSettings"

  describe "settings", ->
    describe "when user settings are defined", ->
      beforeEach ->
        @spy = sinon.spy(TuringEmailApp.Views, "SettingsView")
        @settingsRouter.navigate "settings", trigger: true

      afterEach ->
        @spy.restore()

      it "shows a SettingsView", ->
        expect(@spy).toHaveBeenCalled()

    describe "when user settings are not defined", ->
      beforeEach ->
        TuringEmailApp.models.userSettings = null

      it "will fetch and then render the settings", ->
        fetchSpy = sinon.spy(@settingsRouter, "renderSettingsView")
        @settingsRouter.showSettings()
        @server.respond()
        expect(fetchSpy).toHaveBeenCalled()
