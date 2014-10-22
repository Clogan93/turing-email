describe "UserSettings", ->
  beforeEach ->
    @userSettingsData = FactoryGirl.create("UserSettings")
    
    @server = sinon.fakeServer.create()
    @url = "/api/v1/user_configurations"
    @server.respondWith "GET", @url, JSON.stringify(@userSettingsData)

    @userSettings = new TuringEmailApp.Models.UserSettings()

  afterEach ->
    @server.restore()

  it "has the right url", ->
    expect(@userSettings.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @userSettings.fetch()
      @server.respond()
      
    it "loads the user settings", ->
      validateUserSettings(@userSettingsData, @userSettings.toJSON())
