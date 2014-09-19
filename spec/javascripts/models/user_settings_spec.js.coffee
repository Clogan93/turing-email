describe "UserSettings model", ->
  beforeEach ->
    @userSettings = new TuringEmailApp.Models.UserSettings()

  it "should exist", ->
    expect(TuringEmailApp.Models.UserSettings).toBeDefined()

  it "should have the right url", ->
    expect(@userSettings.url).toEqual "/api/v1/user_configurations.json"

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("user_settings.fixture.json", true);

      @validUserSettings = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/user_configurations.json", JSON.stringify(@validUserSettings)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
        @userSettings.fetch()
        expect(@server.requests.length).toEqual 1
        expect(@server.requests[0].method).toEqual "GET"
        expect(@server.requests[0].url).toEqual "/api/v1/user_configurations.json"
        return

    it "should parse the genie_enabled from the response", ->
        @userSettings.fetch()
        @server.respond()
        expect(@userSettings.get("genie_enabled")).toEqual @validUserSettings.genie_enabled
        return

    it "should have the genie_enabled attribute", ->
      @userSettings.fetch()
      @server.respond()
      expect(@userSettings.get("genie_enabled")).toBeDefined()

    it "should parse the split_pane_mode from the response", ->
        @userSettings.fetch()
        @server.respond()
        expect(@userSettings.get("split_pane_mode")).toEqual @validUserSettings.split_pane_mode
        return

    it "should have the split_pane_mode attribute", ->
      @userSettings.fetch()
      @server.respond()
      expect(@userSettings.get("split_pane_mode")).toBeDefined()
