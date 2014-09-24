describe "SettingsView", ->

  beforeEach ->
    @userSettings = new TuringEmailApp.Models.UserSettings()
    @settingsView = new TuringEmailApp.Views.SettingsView(
      model: @userSettings
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.SettingsView).toBeDefined()

  it "loads the list item template", ->
    expect(@settingsView.template).toEqual JST["backbone/templates/settings"]

  describe "when render is called", ->

    beforeEach ->
      @fixtures = fixture.load("user_settings.fixture.json", true)

      @validUserSettingsFixture = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/user_configurations.json", JSON.stringify(@validUserSettingsFixture)
      @userSettings.fetch()
      @server.respond()
      return

    afterEach ->
      @server.restore()

    it "has setupTheDeclareEmailBankruptcyButton bind the click event to #declare_email_bankruptcy button", ->
      @settingsView.render()
      element = @settingsView.$el.find("#declare_email_bankruptcy")[0]
      events = $._data(element, "events")
      expect(events.hasOwnProperty('click')).toBe true

    it "has setupSaveButton bind the click event to #user_settings_save_button button", ->
      @settingsView.render()
      element = @settingsView.$el.find("#user_settings_save_button")[0]
      events = $._data(element, "events")
      expect(events.hasOwnProperty('click')).toBe true
