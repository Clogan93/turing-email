describe "SettingsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @userSettings = new TuringEmailApp.Models.UserSettings()

    @settingsDiv = $("<div />", {id: "settings"}).appendTo('body')
    @settingsView = new TuringEmailApp.Views.SettingsView(
      el: @settingsDiv
      model: @userSettings
    )

    userSettingsFixtures = fixture.load("user_settings.fixture.json");
    @validUserSettingsFixture = userSettingsFixtures[0]["valid"]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @userSettings.url, JSON.stringify(@validUserSettingsFixture)

  afterEach ->
    @server.restore()
    $(@settingsDiv).remove()

  it "has the right template", ->
    expect(@settingsView.template).toEqual JST["backbone/templates/settings"]

  describe "#render", ->
    beforeEach ->
      @userSettings.fetch()
      @server.respond()
      
      window.confirm = ->
        return true

    it "renders the settings view", ->
      expect(@settingsDiv.find("div[class=page-header]")).toContainHtml('<h1 class="h1">Settings</h1>')

      expect(@settingsDiv).toContainHtml('<h4 class="h4">Keyboard Shortcuts</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Email Genie</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Horizontal Preview Panel</h4>')

    it "renders the Email Bankruptcy button", ->
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Email Bankruptcy</h4>')
      expect(@settingsDiv).toContainHtml('<button id="email_bankruptcy_button" type="button" class="btn btn-block btn-danger">Declare Email Bankruptcy</button>')

      spyOnEvent("#email_bankruptcy_button", "click")
      emailBankruptcyButton = @settingsDiv.find("#email_bankruptcy_button")
      emailBankruptcyButton.click()
      expect("click").toHaveBeenPreventedOn("#email_bankruptcy_button")

      expect(@settingsDiv).toContainText("You have successfully declared email bankruptcy!")
      
      expect(@server.requests.length).toEqual 2
      request = @server.requests[1]
      expect(request.method).toEqual "POST"
      expect(request.url).toEqual "/api/v1/users/declare_email_bankruptcy"

    it "renders the keyboard shortcuts switch", ->
      keyboardShortcutsSwitch = $("#keyboard_shortcuts_switch")
      expect(@settingsDiv).toContain(keyboardShortcutsSwitch)
      # TODO check if checked based on user settings value when it is added

    it "renders the email genie switch", ->
      genieSwitch = $("#genie_switch")
      expect(@settingsDiv).toContain(genieSwitch)
      expect(genieSwitch.is(":checked")).toEqual(@userSettings.get("genie_enabled"))

    it "renders the split pane switch", ->
      splitPaneSwitch = $("#split_pane_switch")
      expect(@settingsDiv).toContain(splitPaneSwitch)
      expect(splitPaneSwitch.is(":checked")).toEqual(@userSettings.get("split_pane_mode") == "horizontal")
      
    it "renders the Save button", ->
      expect(@settingsDiv).toContainHtml('<button type="button" class="btn btn-success" id="user_settings_save_button">Save</button>')

      spyOnEvent("#user_settings_save_button", "click")
      saveButton = @settingsDiv.find("#user_settings_save_button")
      saveButton.click()
      expect("click").toHaveBeenPreventedOn("#user_settings_save_button")

      expect(@server.requests.length).toEqual 2
      request = @server.requests[1]
      expect(request.method).toEqual "POST"
      expect(request.url).toEqual "/api/v1/user_configurations"

    it "updates the user settings model with the correct values", ->
      expect(@userSettings.get("genie_enabled")).toEqual(true)
      expect(@userSettings.get("split_pane_mode")).toEqual("off")
       
      genieSwitch = $("#genie_switch")
      splitPaneSwitch = $("#split_pane_switch")

      genieSwitch.click()
      splitPaneSwitch.click()
      
      saveButton = @settingsDiv.find("#user_settings_save_button")
      saveButton.click()
  
      expect(@userSettings.get("genie_enabled")).toEqual(false)
      expect(@userSettings.get("split_pane_mode")).toEqual("horizontal")
