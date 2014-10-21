describe "SettingsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    brainRulesFixtures = fixture.load("rules/brain_rules.fixture.json", true)
    @validBrainRulesFixture = brainRulesFixtures[0]

    emailRulesFixtures = fixture.load("rules/email_rules.fixture.json", true)
    @validEmailRulesFixture = emailRulesFixtures[0]

    @userSettings = new TuringEmailApp.Models.UserSettings()

    [@server] = specPrepareUserSettingsFetch()

    @server.respondWith "GET", "/api/v1/genie_rules", JSON.stringify(@validBrainRulesFixture)
    TuringEmailApp.collections.brainRules = new TuringEmailApp.Collections.Rules.BrainRulesCollection()
    TuringEmailApp.collections.brainRules.fetch()
    @server.respond()

    @server.respondWith "GET", "/api/v1/email_rules", JSON.stringify(@validEmailRulesFixture)
    TuringEmailApp.collections.emailRules = new TuringEmailApp.Collections.Rules.EmailRulesCollection()
    TuringEmailApp.collections.emailRules.fetch()
    @server.respond()

    @settingsDiv = $("<div />", {id: "settings"}).appendTo("body")
    @settingsView = new TuringEmailApp.Views.SettingsView(
      el: @settingsDiv
      model: @userSettings
      emailRules: TuringEmailApp.collections.emailRules
      brainRules: TuringEmailApp.collections.brainRules
    )

    @userSettings.fetch()
    @server.respond()

  afterEach ->
    @server.restore()
    @settingsDiv.remove()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@settingsView.template).toEqual JST["backbone/templates/settings"]

  describe "#render", ->
    it "renders the settings view", ->
      expect(@settingsDiv.find("div[class=page-header]")).toContainHtml('<h1 class="h1">Settings</h1>')

      expect(@settingsDiv).toContainHtml('<h4 class="h4">Demo Mode</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Keyboard Shortcuts</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Email Genie</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Horizontal Preview Panel</h4>')

    it "renders the Email Bankruptcy button", ->
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Email Bankruptcy</h4>')
      expect(@settingsDiv).toContainHtml('<button id="email_bankruptcy_button" type="button" class="btn btn-block btn-danger">Declare Email Bankruptcy</button>')

    it "renders the demo mode switch", ->
      demoModeSwitch = $(".demo_mode_switch")
      expect(@settingsDiv).toContain(demoModeSwitch)
      expect(demoModeSwitch.is(":checked")).toEqual(@userSettings.get("demo_mode_enabled"))
      
    it "renders the keyboard shortcuts switch", ->
      keyboardShortcutsSwitch = $(".keyboard_shortcuts_switch")
      expect(@settingsDiv).toContain(keyboardShortcutsSwitch)
      expect(keyboardShortcutsSwitch.is(":checked")).toEqual(@userSettings.get("keyboard_shortcuts_enabled"))
      
    it "renders the email genie switch", ->
      genieSwitch = $("#genie_switch")
      expect(@settingsDiv).toContain(genieSwitch)
      expect(genieSwitch.is(":checked")).toEqual(@userSettings.get("genie_enabled"))

    it "renders the split pane switch", ->
      splitPaneSwitch = $("#split_pane_switch")
      expect(@settingsDiv).toContain(splitPaneSwitch)
      expect(splitPaneSwitch.is(":checked")).toEqual(@userSettings.get("split_pane_mode") == "horizontal")

  describe "email bankruptcy button", ->
    describe "the user cancels the action", ->
      beforeEach ->
        window.confirm = ->
          return false
        
      it "does NOT post the bankruptcy request to the server", ->
        spyOnEvent("#email_bankruptcy_button", "click")
        emailBankruptcyButton = @settingsDiv.find("#email_bankruptcy_button")
        emailBankruptcyButton.click()
        expect("click").toHaveBeenPreventedOn("#email_bankruptcy_button")

        expect(@server.requests.length).toEqual 3
        
    describe "the user confirms the action", ->
      beforeEach ->
        window.confirm = ->
          return true
      
      it "posts the bankruptcy request to the server", ->
        spyOnEvent("#email_bankruptcy_button", "click")
        emailBankruptcyButton = @settingsDiv.find("#email_bankruptcy_button")
        emailBankruptcyButton.click()
        expect("click").toHaveBeenPreventedOn("#email_bankruptcy_button")
  
        expect(@server.requests.length).toEqual 4
        request = @server.requests[3]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "/api/v1/users/declare_email_bankruptcy"

      it "show the settings alert", ->
        spy = sinon.spy(@settingsView, "showSettingsAlert")
        emailBankruptcyButton = @settingsDiv.find("#email_bankruptcy_button")
        emailBankruptcyButton.click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

  describe "#saveSettings", ->

    it "is called by the switch change event on the switches", ->
      spy = sinon.spy(@settingsView, "saveSettings")
      @settingsView.$el.find("#genie_rules_button").click()
      genieSwitch = @settingsView.$el.find("#genie_switch")
      genieSwitch.click()
      expect(spy).toHaveBeenCalled()
      spy.restore()

    describe "when saveSettings is called", ->

      it "patches the server", ->
        @settingsView.$el.find("#genie_rules_button").click()
        genieSwitch = @settingsView.$el.find("#genie_switch")
        genieSwitch.click()
        expect(@server.requests.length).toEqual 4
        request = @server.requests[3]
        expect(request.method).toEqual "PATCH"
        expect(request.url).toEqual "/api/v1/user_configurations"
        @server.restore()

      it "updates the user settings model with the correct values", ->
        expect(@userSettings.get("genie_enabled")).toEqual(true)
        expect(@userSettings.get("split_pane_mode")).toEqual("horizontal")

        splitPaneSwitch = $("#split_pane_switch")
        splitPaneSwitch.click()

        expect(@userSettings.get("genie_enabled")).toEqual(true)
        expect(@userSettings.get("split_pane_mode")).toEqual("off")
        @server.restore()

      it "displays a success alert after the save button is clicked and then hides it", ->
        @clock = sinon.useFakeTimers()

        showSettingsAlertSpy = sinon.spy(@settingsView, "showSettingsAlert")
        removeSettingsAlertSpy = sinon.spy(@settingsView, "removeSettingsAlert")

        @settingsView.saveSettings()

        @server.respondWith "PATCH", @userSettings.url, JSON.stringify(@userSettings)
        @server.respond()

        expect(showSettingsAlertSpy).toHaveBeenCalled()

        @clock.tick(5000)

        expect(removeSettingsAlertSpy).toHaveBeenCalled()

        @clock.restore()
        @server.restore()

  describe "#setupRuleCreation", ->

    it "binds the click event to the email rules button", ->
      expect(@settingsView.$el.find("#email_rules_button")).toHandle("click")

    describe "when the email rules button is clicked", ->

      it "shows the create rules view in email_rule mode", ->
        spy = sinon.spy(@settingsView.createRulesView, "show")
        @settingsView.$el.find("#email_rules_button").click()
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith("email_rule")
        spy.restore()

    it "binds the click event to the brain rules button", ->
      expect(@settingsView.$el.find("#genie_rules_button")).toHandle("click")

    describe "when the brain rules button is clicked", ->

      it "shows the create rules view in genie_rule mode", ->
        spy = sinon.spy(@settingsView.createRulesView, "show")
        @settingsView.$el.find("#genie_rules_button").click()
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith("genie_rule")
        spy.restore()

  describe "#setupRuleDeletion", ->

    it "binds the click event to the email rule table's rule deletion button", ->
      expect(@settingsView.$el.find(".email-rules-table .rule-deletion-button")).toHandle("click")

    describe "clicking on the email rule table's rule deletion button", ->

      it "deletes the associated rule and removes its element from the DOM", ->
        removeSpy = sinon.spy($.prototype, "remove")

        firstDeleteButton = @settingsView.$el.find(".email-rules-table .rule-deletion-button").first()
        firstDeleteButton.click()

        expect(@server.requests.length).toEqual 4
        request = @server.requests[3]
        expect(request.method).toEqual "DELETE"
        expect(request.url).toEqual "/api/v1/email_rules/" + firstDeleteButton.attr("data") + ".json"

        expect(removeSpy).toHaveBeenCalled()
        removeSpy.restore()

    it "binds the click event to the brain rule table's rule deletion button", ->
      expect(@settingsView.$el.find(".brain-rules-table .rule-deletion-button")).toHandle("click")

    describe "clicking on the brain rule table's rule deletion button", ->

      it "deletes the associated rule and removes its element from the DOM", ->
        removeSpy = sinon.spy($.prototype, "remove")

        firstDeleteButton = @settingsView.$el.find(".brain-rules-table .rule-deletion-button").first()
        firstDeleteButton.click()

        expect(@server.requests.length).toEqual 4
        request = @server.requests[3]
        expect(request.method).toEqual "DELETE"
        expect(request.url).toEqual "/api/v1/genie_rules/" + firstDeleteButton.attr("data") + ".json"

        expect(removeSpy).toHaveBeenCalled()
        removeSpy.restore()

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
