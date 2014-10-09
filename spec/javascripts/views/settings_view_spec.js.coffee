describe "SettingsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @userSettings = new TuringEmailApp.Models.UserSettings()

    @settingsDiv = $("<div />", {id: "settings"}).appendTo("body")
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
    @settingsDiv.remove()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@settingsView.template).toEqual JST["backbone/templates/settings"]

  describe "#render", ->
    beforeEach ->
      @userSettings.fetch()
      @server.respond()

    it "renders the settings view", ->
      expect(@settingsDiv.find("div[class=page-header]")).toContainHtml('<h1 class="h1">Settings</h1>')

      expect(@settingsDiv).toContainHtml('<h4 class="h4">Keyboard Shortcuts</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Email Genie</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Horizontal Preview Panel</h4>')

    it "renders the Email Bankruptcy button", ->
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Email Bankruptcy</h4>')
      expect(@settingsDiv).toContainHtml('<button id="email_bankruptcy_button" type="button" class="btn btn-block btn-danger">Declare Email Bankruptcy</button>')

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

  describe "email bankruptcy button", ->
    beforeEach ->
      @userSettings.fetch()
      @server.respond()

    describe "the user cancels the action", ->
      beforeEach ->
        window.confirm = ->
          return false
        
      it "does NOT post the bankruptcy request to the server", ->
        spyOnEvent("#email_bankruptcy_button", "click")
        emailBankruptcyButton = @settingsDiv.find("#email_bankruptcy_button")
        emailBankruptcyButton.click()
        expect("click").toHaveBeenPreventedOn("#email_bankruptcy_button")

        expect(@server.requests.length).toEqual 1
        
    describe "the user confirms the action", ->
      beforeEach ->
        window.confirm = ->
          return true
      
      it "posts the bankruptcy request to the server", ->
        spyOnEvent("#email_bankruptcy_button", "click")
        emailBankruptcyButton = @settingsDiv.find("#email_bankruptcy_button")
        emailBankruptcyButton.click()
        expect("click").toHaveBeenPreventedOn("#email_bankruptcy_button")
  
        expect(@server.requests.length).toEqual 2
        request = @server.requests[1]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "/api/v1/users/declare_email_bankruptcy"

      it "show the settings alert", ->
        spy = sinon.spy(@settingsView, "showSettingsAlert")
        emailBankruptcyButton = @settingsDiv.find("#email_bankruptcy_button")
        emailBankruptcyButton.click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

  describe "save button", ->
    beforeEach ->
      @userSettings.fetch()
      @server.respond()
      
    it "saves the model to the server", ->
      spyOnEvent("#user_settings_save_button", "click")
      saveButton = @settingsDiv.find("#user_settings_save_button")
      saveButton.click()
      expect("click").toHaveBeenPreventedOn("#user_settings_save_button")

      expect(@server.requests.length).toEqual 2
      request = @server.requests[1]
      expect(request.method).toEqual "PATCH"
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

    it "displays a success alert after the save button is clicked and then hides it", ->
      showSettingsAlertSpy = sinon.spy(@settingsView, "showSettingsAlert")
      removeSettingsAlertSpy = sinon.spy(@settingsView, "removeSettingsAlert")

      #Change one attribute
      expect(@userSettings.get("genie_enabled")).toEqual(true)
      genieSwitch = $("#genie_switch")
      genieSwitch.click()
      saveButton = @settingsDiv.find("#user_settings_save_button")
      saveButton.click()

      @server.respondWith "PATCH", @userSettings.url, JSON.stringify(@userSettings)
      @server.respond()

      expect(showSettingsAlertSpy).toHaveBeenCalled()

      waitsFor ->
        return removeSettingsAlertSpy.callCount == 1

  describe "#showSettingsAlert", ->
    
    describe "when the current alert token is defined", ->
      beforeEach ->
        @settingsView.currentAlertToken = true

      it "should remove the alert", ->
        spy = sinon.spy(@settingsView, "removeSettingsAlert")
        @settingsView.showSettingsAlert()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    it "should show the alert", ->
      spy = sinon.spy(TuringEmailApp, "showAlert")
      @settingsView.showSettingsAlert()
      expect(spy).toHaveBeenCalled()
      spy.restore()

    it "should set the current alert token", ->
      @settingsView.currentAlertToken = null
      @settingsView.showSettingsAlert()
      expect(@settingsView.currentAlertToken).toBeDefined()

  describe "#removeSettingsAlert", ->
    
    describe "when the current alert token is defined", ->
      beforeEach ->
        @settingsView.currentAlertToken = true

      it "should remove the alert", ->
        spy = sinon.spy(TuringEmailApp, "removeAlert")
        @settingsView.removeSettingsAlert()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      it "should set the current alert token to be null", ->
        @settingsView.removeSettingsAlert()
        expect(@settingsView.currentAlertToken is null).toBeTruthy()
