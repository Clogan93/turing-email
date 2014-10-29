describe "SettingsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    brainRulesFixtures = fixture.load("rules/brain_rules.fixture.json", true)
    @validBrainRulesFixture = brainRulesFixtures[0]

    emailRulesFixtures = fixture.load("rules/email_rules.fixture.json", true)
    @validEmailRulesFixture = emailRulesFixtures[0]

    @server = sinon.fakeServer.create()

    @server.respondWith "GET", "/api/v1/genie_rules", JSON.stringify(@validBrainRulesFixture)
    TuringEmailApp.collections.brainRules = new TuringEmailApp.Collections.Rules.BrainRulesCollection()
    TuringEmailApp.collections.brainRules.fetch()
    @server.respond()

    @server.respondWith "GET", "/api/v1/email_rules", JSON.stringify(@validEmailRulesFixture)
    TuringEmailApp.collections.emailRules = new TuringEmailApp.Collections.Rules.EmailRulesCollection()
    TuringEmailApp.collections.emailRules.fetch()
    @server.respond()

    @userSettings = new TuringEmailApp.Models.UserSettings()
    
    @settingsDiv = $("<div />", {id: "settings"}).appendTo("body")
    @settingsView = new TuringEmailApp.Views.SettingsView(
      el: @settingsDiv
      model: @userSettings
      emailRules: TuringEmailApp.collections.emailRules
      brainRules: TuringEmailApp.collections.brainRules
    )
    
    @userSettings.set(FactoryGirl.create("UserSettings"))

  afterEach ->
    @server.restore()
    @settingsDiv.remove()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@settingsView.template).toEqual JST["backbone/templates/app/settings"]

  describe "#render", ->
    it "renders the settings view", ->
      expect(@settingsDiv.find("div[class=page-header]")).toContainHtml('<h1 class="h1">Settings</h1>')

      expect(@settingsDiv).toContainHtml('<h4 class="h4">Demo Mode</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Keyboard Shortcuts</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Email Genie</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Horizontal Preview Panel</h4>')

    it "renders the Email Bankruptcy button", ->
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Email Bankruptcy</h4>')
      expect(@settingsDiv).toContainHtml('<button type="button" class="btn btn-block btn-danger email-bankruptcy-button">Declare Email Bankruptcy</button>')

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

    it "renders the email rules table", ->
      emailRulesTable = $(".email-rules-table")
      expect(@settingsDiv).toContain(emailRulesTable)

    it "renders the email rules", ->
      emailRule = TuringEmailApp.collections.emailRules.models[0]
      expect(@settingsDiv.find(".email-rule")).toContainHtml('<td>' + emailRule.get("from_address") + '</td>')
      expect(@settingsDiv.find(".email-rule")).toContainHtml('<td>' + emailRule.get("to_address") + '</td>')
      expect(@settingsDiv.find(".email-rule")).toContainHtml('<td>' + emailRule.get("subject") + '</td>')
      expect(@settingsDiv.find(".email-rule")).toContainHtml('<td>' + emailRule.get("list_id") + '</td>')
      expect(@settingsDiv.find(".email-rule")).toContainHtml('<td>' + emailRule.get("destination_folder_name") + '</td>')

    it "renders the brain rules table", ->
      brainRulesTable = $(".brain-rules-table")
      expect(@settingsDiv).toContain(brainRulesTable)

    it "renders the brain rules", ->
      brainRule = TuringEmailApp.collections.brainRules.models[0]
      from_address = if brainRule.get("from_address")? then brainRule.get("from_address") else ""
      to_address = if brainRule.get("to_address")? then brainRule.get("to_address") else ""
      subject = if brainRule.get("subject")? then brainRule.get("subject") else ""
      list_id = if brainRule.get("list_id")? then brainRule.get("list_id") else ""
      expect(@settingsDiv.find(".brain-rule").first()).toContainHtml('<td>' + from_address + '</td>')
      expect(@settingsDiv.find(".brain-rule").first()).toContainHtml('<td>' + to_address + '</td>')
      expect(@settingsDiv.find(".brain-rule").first()).toContainHtml('<td>' + subject + '</td>')
      expect(@settingsDiv.find(".brain-rule").first()).toContainHtml('<td>' + list_id + '</td>')

  describe "#setupSwitches", ->

    it "sets up the demo mode switch", ->
      @settingsView.setupSwitches()
      expect(@settingsDiv.find(".demo_mode_switch").parent().parent()).toHaveClass "has-switch"

    it "sets up the keyboard shortcuts switch", ->
      @settingsView.setupSwitches()
      expect(@settingsDiv.find(".keyboard_shortcuts_switch").parent().parent()).toHaveClass "has-switch"

      @settingsView.setupSwitches()
    it "sets up the genie switch", ->
      expect(@settingsDiv.find("#genie_switch").parent().parent()).toHaveClass "has-switch"

    it "sets up the split pane switch", ->
      @settingsView.setupSwitches()
      expect(@settingsDiv.find("#split_pane_switch").parent().parent()).toHaveClass "has-switch"

  describe "#setupEmailBankruptcyButton", ->
    describe "the user cancels the action", ->
      beforeEach ->
        window.confirm = ->
          return false
        
      it "does NOT post the bankruptcy request to the server", ->
        spyOnEvent(".email-bankruptcy-button", "click")
        emailBankruptcyButton = @settingsDiv.find(".email-bankruptcy-button")
        emailBankruptcyButton.click()
        expect("click").toHaveBeenPreventedOn(".email-bankruptcy-button")

        expect(@server.requests.length).toEqual 2
        
    describe "the user confirms the action", ->
      beforeEach ->
        window.confirm = ->
          return true
      
      it "posts the bankruptcy request to the server", ->
        spyOnEvent(".email-bankruptcy-button", "click")
        emailBankruptcyButton = @settingsDiv.find(".email-bankruptcy-button")
        emailBankruptcyButton.click()
        expect("click").toHaveBeenPreventedOn(".email-bankruptcy-button")
  
        expect(@server.requests.length).toEqual 3
        request = @server.requests[2]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "/api/v1/users/declare_email_bankruptcy"

      it "show the settings alert", ->
        spy = sinon.spy(@settingsView, "showSettingsAlert")
        emailBankruptcyButton = @settingsDiv.find(".email-bankruptcy-button")
        emailBankruptcyButton.click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

  describe "#saveSettings", ->

    it "is called by the switch change event on the switches", ->
      spy = sinon.spy(@settingsView, "saveSettings")
      @settingsView.$el.find(".genie-rules-button").click()
      genieSwitch = @settingsView.$el.find("#genie_switch")
      genieSwitch.click()
      expect(spy).toHaveBeenCalled()
      spy.restore()

    describe "when saveSettings is called", ->

      it "patches the server", ->
        @settingsView.$el.find(".genie-rules-button").click()
        genieSwitch = @settingsView.$el.find("#genie_switch")
        genieSwitch.click()
        expect(@server.requests.length).toEqual 3
        request = @server.requests[2]
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

        showSettingsAlertSpy.restore()
        removeSettingsAlertSpy.restore()

  describe "#setupRuleCreation", ->

    it "binds the click event to the email rules button", ->
      expect(@settingsView.$el.find(".email-rules-button")).toHandle("click")

    describe "when the email rules button is clicked", ->

      it "shows the create rules view in email_rule mode", ->
        spy = sinon.spy(@settingsView.createRulesView, "show")
        @settingsView.$el.find(".email-rules-button").click()
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith("email_rule")
        spy.restore()

    it "binds the click event to the brain rules button", ->
      expect(@settingsView.$el.find(".genie-rules-button")).toHandle("click")

    describe "when the brain rules button is clicked", ->

      it "shows the create rules view in genie_rule mode", ->
        spy = sinon.spy(@settingsView.createRulesView, "show")
        @settingsView.$el.find(".genie-rules-button").click()
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

        expect(@server.requests.length).toEqual 3
        request = @server.requests[2]
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

        expect(@server.requests.length).toEqual 3
        request = @server.requests[2]
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
