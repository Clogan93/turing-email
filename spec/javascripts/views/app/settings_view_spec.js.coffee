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
    
    skins = new TuringEmailApp.Collections.SkinsCollection(FactoryGirl.createLists("Skin", FactoryGirl.SMALL_LIST_SIZE))

    @userConfiguration = new TuringEmailApp.Models.UserConfiguration()
    
    @settingsDiv = $("<div />", {id: "settings"}).appendTo("body")
    @settingsView = new TuringEmailApp.Views.SettingsView(
      el: @settingsDiv
      model: @userConfiguration
      emailRules: TuringEmailApp.collections.emailRules
      brainRules: TuringEmailApp.collections.brainRules
      skins: skins
    )
    
    @userConfiguration.set(FactoryGirl.create("UserConfiguration"))

  afterEach ->
    @server.restore()
    @settingsDiv.remove()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@settingsView.template).toEqual JST["backbone/templates/app/settings"]

  describe "#render", ->
    it "renders the settings view", ->
      expect(@settingsDiv.find("div[class=col-md-10]")).toContainHtml('<h1 class="h1">Settings</h1>')

      expect(@settingsDiv).toContainHtml('<h4 class="h4">Keyboard Shortcuts</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Inbox Cleaner</h4>')
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Horizontal Preview Panel</h4>')

    it "renders the tabs", ->
      expect(@settingsDiv.find("a[href=#tab-1]").text()).toEqual("General")
      expect(@settingsDiv.find("a[href=#tab-2]").text()).toEqual("Rules")
      expect(@settingsDiv.find("a[href=#tab-3]").text()).toEqual("Installed Apps")
      expect(@settingsDiv.find("a[href=#tab-4]").text()).toEqual("Bankruptcy")
      
    it "renders the Email Bankruptcy button", ->
      expect(@settingsDiv).toContainHtml('<h4 class="h4">Email Bankruptcy</h4>')
      expect(@settingsDiv).toContainHtml('<button type="button" class="btn btn-block btn-danger email-bankruptcy-button">Declare Email Bankruptcy</button>')

    it "renders the keyboard shortcuts switch", ->
      keyboardShortcutsSwitch = $(".keyboard-shortcuts-switch")
      expect(@settingsDiv).toContain(keyboardShortcutsSwitch)
      expect(keyboardShortcutsSwitch.is(":checked")).toEqual(@userConfiguration.get("keyboard_shortcuts_enabled"))
      
    it "renders the email genie switch", ->
      genieSwitch = $(".genie-switch")
      expect(@settingsDiv).toContain(genieSwitch)
      expect(genieSwitch.is(":checked")).toEqual(@userConfiguration.get("genie_enabled"))

    it "renders the split pane switch", ->
      splitPaneSwitch = $(".split-pane-switch")
      expect(@settingsDiv).toContain(splitPaneSwitch)
      expect(splitPaneSwitch.is(":checked")).toEqual(@userConfiguration.get("split_pane_mode") == "horizontal")

    it "renders the auto cleaner switch", ->
      autoCleanerSwitch = $(".auto-cleaner-switch")
      expect(@settingsDiv).toContain(autoCleanerSwitch)
      expect(autoCleanerSwitch.is(":checked")).toEqual(@userConfiguration.get("auto_cleaner_enabled"))
      
    it "renders the developer switch", ->
      developerSwitch = $(".developer-switch")
      expect(@settingsDiv).toContain(developerSwitch)
      expect(developerSwitch.is(":checked")).toEqual(@userConfiguration.get("developer_enabled"))

    it "renders the inbox tabs switch", ->
      inboxTabsSwitch = $(".inbox-tabs-switch")
      expect(@settingsDiv).toContain(inboxTabsSwitch)
      expect(inboxTabsSwitch.is(":checked")).toEqual(@userConfiguration.get("inbox_tabs_enabled"))

    it "renders the skin select", ->
      skinSelect = $(".skin-select")
      expect(@settingsDiv).toContain(skinSelect)
      
    describe "with selected tab", ->
      beforeEach ->
        @selectedTabID = "tab-3"
        @selector = "a[href=#" + @selectedTabID + "]"
        $(@selector).click()

        @newSelectedTabID = $(".tab-pane.active").attr("id")
        
      it "selects the tab", ->
        expect(@newSelectedTabID).toEqual(@selectedTabID)

  describe "email bankruptcy button", ->
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

    it "renders the installed apps table", ->
      installedAppsTable = $(".installed-apps-table")
      expect(@settingsDiv).toContain(installedAppsTable)

    it "renders the installed apps information", ->
      installedAppsTable = $(".installed-apps-table")
      for installedApp, index in @userConfiguration.toJSON().installed_apps
        expect(@settingsDiv.find(".installed-app")[index]).toContainHtml('<td>' + installedApp.app.name + '</td>')
        expect(@settingsDiv.find(".installed-app")[index]).toContainHtml('<td>' + installedApp.app.description + '</td>')

  describe "#setupSwitches", ->

    it "sets up the keyboard shortcuts switch", ->
      @settingsView.setupSwitches()
      expect(@settingsDiv.find(".keyboard-shortcuts-switch").parent().parent()).toHaveClass "has-switch"

      @settingsView.setupSwitches()
    it "sets up the genie switch", ->
      expect(@settingsDiv.find(".genie-switch").parent().parent()).toHaveClass "has-switch"

    it "sets up the split pane switch", ->
      @settingsView.setupSwitches()
      expect(@settingsDiv.find(".split-pane-switch").parent().parent()).toHaveClass "has-switch"

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
        spy = sinon.spy(TuringEmailApp, "showAlert")
        emailBankruptcyButton = @settingsDiv.find(".email-bankruptcy-button")
        emailBankruptcyButton.click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

  describe "#saveSettings", ->
    it "is called by the switch change event on the switches", ->
      spy = sinon.spy(@settingsView, "saveSettings")
      @settingsView.$el.find(".genie-rules-button").click()

      genieSwitch = @settingsView.$el.find(".genie-switch")
      genieSwitch.click()
      expect(spy).toHaveBeenCalled()
      spy.restore()

    describe "when saveSettings is called", ->
      it "patches the server", ->
        @settingsView.$el.find(".genie-rules-button").click()

        genieSwitch = @settingsView.$el.find(".genie-switch")
        genieSwitch.click()
        
        expect(@server.requests.length).toEqual 3
        
        request = @server.requests[2]
        
        expect(request.method).toEqual "PATCH"
        expect(request.url).toEqual "/api/v1/user_configurations"

      it "updates the user settings model with the correct values", ->
        expect(@userConfiguration.get("genie_enabled")).toEqual(true)
        expect(@userConfiguration.get("split_pane_mode")).toEqual("horizontal")

        splitPaneSwitch = $(".split-pane-switch")
        splitPaneSwitch.click()

        expect(@userConfiguration.get("genie_enabled")).toEqual(true)
        expect(@userConfiguration.get("split_pane_mode")).toEqual("off")

      it "displays a success alert after the save button is clicked and then hides it", ->
        @clock = sinon.useFakeTimers()

        showAlertSpy = sinon.spy(TuringEmailApp, "showAlert")
        removeAlertSpy = sinon.spy(TuringEmailApp, "removeAlert")

        @settingsView.saveSettings()

        @server.respondWith "PATCH", @userConfiguration.url, stringifyUserConfiguration(@userConfiguration)
        @server.respond()

        expect(showAlertSpy).toHaveBeenCalled()

        @clock.tick(5000)

        expect(removeAlertSpy).toHaveBeenCalled()

        @clock.restore()
        @server.restore()

        showAlertSpy.restore()
        removeAlertSpy.restore()

  describe "#setupUninstallAppButtons", ->
    it "binds the uninstall button's click event", ->
      expect(@settingsView.$el.find(".uninstall-app-button")).toHandle("click")

    describe "clicking on the uninstall app button", ->
      beforeEach ->
        @triggerStub = sinon.stub(@settingsView, "trigger")
        @removeSpy = sinon.spy($.prototype, "remove")
        
      afterEach ->
        @removeSpy.restore()
        @triggerStub.restore()
      
      it "triggers uninstallAppClicked and removes its element from the DOM", ->
        index = 0
        
        for uninstallButton in @settingsView.$el.find(".uninstall-app-button")
          uninstallButton = $(uninstallButton)
          @removeSpy.reset()
          
          uninstallButton.click()
          appID = uninstallButton.attr("data")
          
          expect(@triggerStub).toHaveBeenCalledWith("uninstallAppClicked", @settingsView, appID)
          expect(@removeSpy).toHaveBeenCalled()
          
          index += 1
        
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
        expect(request.url).toEqual "/api/v1/email_rules/" + firstDeleteButton.attr("data")

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
        expect(request.url).toEqual "/api/v1/genie_rules/" + firstDeleteButton.attr("data")

        expect(removeSpy).toHaveBeenCalled()
        removeSpy.restore()
