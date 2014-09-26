describe "UserSettings", ->
  beforeEach ->
    userSettingsFixtures = fixture.load("user_settings.fixture.json");
    @validUserSettingsFixture = userSettingsFixtures[0]["valid"]
    
    @userSettings = new TuringEmailApp.Models.UserSettings()

    @server = sinon.fakeServer.create()
    
    @url = "/api/v1/user_configurations"
    @server.respondWith "GET", @url, JSON.stringify(@validUserSettingsFixture)

  afterEach ->
    @server.restore()

  it "has the right url", ->
    expect(@userSettings.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @userSettings.fetch()
      @server.respond()
      
    it "loads the user settings", ->
      validateUserSettingsAttributes(@userSettings.toJSON())
