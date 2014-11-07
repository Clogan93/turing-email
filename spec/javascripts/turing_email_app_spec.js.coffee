describe "TuringEmailApp", ->
  beforeEach ->
    window.gapi = client: load: => return then: =>

    @server = sinon.fakeServer.create()
    @mainDiv = $("<div />", id: "main").appendTo($("body"))
    
    @syncEmailStub = sinon.stub(TuringEmailApp, "syncEmail")

  afterEach ->
    @server.restore()
    @mainDiv.remove()
    @syncEmailStub.restore()
    
  it "has the app objects defined", ->
    expect(TuringEmailApp.Models).toBeDefined()
    expect(TuringEmailApp.Views).toBeDefined()
    expect(TuringEmailApp.Collections).toBeDefined()
    expect(TuringEmailApp.Routers).toBeDefined()
    
  describe "#threadsListInboxCountRequest", ->
    beforeEach ->
      window.gapi = client: gmail: users: messages: list: ->

      @ret = {}
      @messagesListStub = sinon.stub(gapi.client.gmail.users.messages, "list", => return @ret)

      @params =
        userId: "me"
        labelIds: "INBOX"
        fields: "resultSizeEstimate"

    afterEach ->
      @messagesListStub.restore()

    it "prepares and returns the Gmail API request", ->
      @returned = TuringEmailApp.threadsListInboxCountRequest()

      expect(@messagesListStub).toHaveBeenCalledWith(@params)
      expect(@returned).toEqual(@ret)
    
  # TODO change to view
  describe "#renderSyncingEmailsMessage", ->
      
  describe "#start", ->
    it "defines the model, view, collection, and router containers", ->
      TuringEmailApp.start(FactoryGirl.create("User"), FactoryGirl.create("UserSettings"))
      
      expect(TuringEmailApp.models).toBeDefined()
      expect(TuringEmailApp.views).toBeDefined()
      expect(TuringEmailApp.collections).toBeDefined()
      expect(TuringEmailApp.routers).toBeDefined()

    setupFunctions = ["setupKeyboardHandler", "setupMainView", "setupSearchBar", "setupComposeButton",
                      "setupToolbar", "setupUser", "setupGmailAPI", "setupEmailFolders", "loadEmailFolders", "setupComposeView",
                      "setupCreateFolderView", "setupEmailThreads", "setupRouters"]

    for setupFunction in setupFunctions  
      it "calls the " + setupFunction + " function", ->
        spy = sinon.spy(TuringEmailApp, setupFunction)
        TuringEmailApp.start(FactoryGirl.create("User"), FactoryGirl.create("UserSettings"))
        expect(spy).toHaveBeenCalled()
        spy.restore()
        
    it "calls syncEmail", ->
      @syncEmailStub.restore()
      @syncEmailStub = sinon.stub(TuringEmailApp, "syncEmail")
      TuringEmailApp.start(FactoryGirl.create("User"), FactoryGirl.create("UserSettings"))
      expect(@syncEmailStub).toHaveBeenCalled()

  it "starts the threadsListInboxCountRequest", ->
      @googleRequestStub = sinon.stub(window, "googleRequest", ->)

      userJSON = FactoryGirl.create("User")
      userJSON.has_genie_report_ran = false
      TuringEmailApp.start(userJSON, FactoryGirl.create("UserSettings"))
      
      expect(@googleRequestStub.args[0][0]).toEqual(TuringEmailApp)
      specCompareFunctions((=> @threadsListInboxCountRequest()), @googleRequestStub.args[0][1])
      specCompareFunctions(((response) => @renderSyncingEmailsMessage(response.result.resultSizeEstimate)), @googleRequestStub.args[0][2])
      
      @googleRequestStub.restore()

  it "starts the backbone history", ->
      TuringEmailApp.start(FactoryGirl.create("User"), FactoryGirl.create("UserSettings"))
      expect(Backbone.History.started).toBeTruthy()

  describe "setup functions", ->
    describe "#setupKeyboardHandler", ->
      beforeEach ->
        TuringEmailApp.setupKeyboardHandler()
        
      it "creates the keyboard handler", ->
        expect(TuringEmailApp.keyboardHandler).toBeDefined()
      
    describe "#setupMainView", ->
      beforeEach ->
        TuringEmailApp.setupMainView()
        
      it "creates the main view", ->
        expect(TuringEmailApp.views.mainView).toBeDefined()

    describe "#setupSearchBar", ->
      beforeEach ->
        @divSearchForm = $('<form role="search" class="navbar-form-custom top-search-form"></form>').appendTo("body")
        
        TuringEmailApp.setupSearchBar()
       
      afterEach ->
        @divSearchForm.remove()
  
      it "hooks the submit action on the header search form", ->
        expect(@divSearchForm).toHandle("submit")
       
      it "prevents the default submit action", ->
        selector = ".top-search-form"
        spyOnEvent(selector, "submit")

        @divSearchForm.submit()
        
        expect("submit").toHaveBeenPreventedOn(selector)
        
      it "searches on submit", ->
        @spy = sinon.spy(TuringEmailApp, "searchClicked")
        
        @divSearchForm.submit()
        
        expect(@spy).toHaveBeenCalled()
        @spy.restore()
        
    describe "#setupComposeButton", ->
      beforeEach ->
        @divComposeButton = $('<button class="compose-button" type="button">Compose Email</button>').appendTo("body")
        
        TuringEmailApp.setupComposeButton()
        
      afterEach ->
        @divComposeButton.remove()
        
      it "hooks the click action on the compose button", ->
        expect(@divComposeButton).toHandle("click")
  
      it "loads an empty compose view on click", ->
        @spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmpty")
  
        @divComposeButton.click()
  
        expect(@spy).toHaveBeenCalled()
        @spy.restore()

      it "shows the compose view on click", ->
        @spy = sinon.spy(TuringEmailApp.views.composeView, "show")

        @divComposeButton.click()

        expect(@spy).toHaveBeenCalled()
        @spy.restore()

    describe "#setupToolbar", ->
      it "creates the toolbar view", ->
        TuringEmailApp.setupToolbar()
    
        expect(TuringEmailApp.views.toolbarView).toBeDefined()
        expect(TuringEmailApp.views.toolbarView.app).toEqual(TuringEmailApp)
        
      it "renders the toolbar view", ->
        # TODO figure out how to test render
        return
  
      toolbarViewEvents = ["checkAllClicked", "checkAllReadClicked", "checkAllUnreadClicked", "uncheckAllClicked",
                           "readClicked", "unreadClicked", "archiveClicked", "trashClicked",
                           "leftArrowClicked", "rightArrowClicked",
                           "labelAsClicked", "moveToFolderClicked", "refreshClicked", "searchClicked",
                           "createNewLabelClicked", "createNewEmailFolderClicked", "demoModeSwitchClicked"]
      for event in toolbarViewEvents
        it "hooks the toolbar " + event + " event", ->
          spy = sinon.spy(TuringEmailApp, event)
          
          TuringEmailApp.setupToolbar()
          TuringEmailApp.views.toolbarView.trigger(event)
          
          expect(spy).toHaveBeenCalled()
          spy.restore()
        
      it "triggers a change:toolbarView event", ->
        spy = sinon.backbone.spy(TuringEmailApp, "change:toolbarView")
        TuringEmailApp.setupToolbar()
        expect(spy).toHaveBeenCalled()
        spy.restore()
  
    describe "#setupUser", ->
      beforeEach ->
        @listenToSpy = sinon.spy(TuringEmailApp, "listenTo")
        TuringEmailApp.setupUser(FactoryGirl.create("User"), FactoryGirl.create("UserSettings"))
      
      afterEach ->
        @listenToSpy.restore()
        
      it "create the user", ->
        expect(TuringEmailApp.models.user instanceof TuringEmailApp.Models.User).toBeTruthy()

      it "create the user settings", ->
        expect(TuringEmailApp.models.userSettings instanceof TuringEmailApp.Models.UserSettings).toBeTruthy()

      it "listens for change:demo_mode_enabled", ->
        expect(@listenToSpy.args[0][0] instanceof TuringEmailApp.Models.UserSettings).toBeTruthy()
        expect(@listenToSpy.args[0][1]).toEqual("change:demo_mode_enabled")
        
      it "listens for change:keyboard_shortcuts_enabled", ->
        expect(@listenToSpy.args[1][0] instanceof TuringEmailApp.Models.UserSettings).toBeTruthy()
        expect(@listenToSpy.args[1][1]).toEqual("change:keyboard_shortcuts_enabled")
        
      describe "the userSettings keyboard_shortcuts_enabled attribute changes", ->
        beforeEach ->
          @keyboardHandlerStartStub = sinon.stub(TuringEmailApp.keyboardHandler, "start")
          @keyboardHandlerStopStub = sinon.stub(TuringEmailApp.keyboardHandler, "stop")

        afterEach ->
          @keyboardHandlerStartStub.restore()
          @keyboardHandlerStopStub.restore()
          
        describe "to true", ->
          beforeEach ->
            TuringEmailApp.models.userSettings.set("keyboard_shortcuts_enabled", false, silent: true)
            TuringEmailApp.models.userSettings.set("keyboard_shortcuts_enabled", true)
            
          it "starts the keyboard shortcuts handler", ->
            expect(@keyboardHandlerStartStub).toHaveBeenCalled()
            expect(@keyboardHandlerStopStub).not.toHaveBeenCalled()

        describe "to false", ->
          beforeEach ->
            TuringEmailApp.models.userSettings.set("keyboard_shortcuts_enabled", true, silent: true)
            TuringEmailApp.models.userSettings.set("keyboard_shortcuts_enabled", false)
            
          it "stops the keyboard shortcuts handler", ->
            expect(@keyboardHandlerStartStub).not.toHaveBeenCalled()
            expect(@keyboardHandlerStopStub).toHaveBeenCalled()

    describe "#setupEmailFolders", ->
      it "creates the email folders collection and tree view", ->
        TuringEmailApp.setupEmailFolders()
        
        expect(TuringEmailApp.collections.emailFolders).toBeDefined()
        expect(TuringEmailApp.views.emailFoldersTreeView).toBeDefined()
  
        expect(TuringEmailApp.views.emailFoldersTreeView.collection).toEqual(TuringEmailApp.collections.emailFolders)
        expect(TuringEmailApp.views.emailFoldersTreeView.app).toEqual(TuringEmailApp)
  
  
      it "hooks the toolbar emailFolderSelected event", ->
        spy = sinon.spy(TuringEmailApp, "emailFolderSelected")
  
        TuringEmailApp.setupEmailFolders()
        TuringEmailApp.views.emailFoldersTreeView.trigger("emailFolderSelected")
  
        expect(spy).toHaveBeenCalled()
        spy.restore()
        
    describe "#setupComposeView", ->
      it "creates the compose view", ->
        TuringEmailApp.setupComposeView()

        expect(TuringEmailApp.views.composeView).toBeDefined()
        expect(TuringEmailApp.views.composeView.app).toEqual(TuringEmailApp)

      it "renders the compose view", ->
        # TODO figure out how to test render
        return
  
      it "hooks the compose view change:draft event", ->
        spy = sinon.spy(TuringEmailApp, "draftChanged")
  
        TuringEmailApp.setupComposeView()
        TuringEmailApp.views.composeView.trigger("change:draft")
  
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "#setupCreateFolderView", ->
      it "creates the create folder view", ->
        TuringEmailApp.setupCreateFolderView()

        expect(TuringEmailApp.views.createFolderView).toBeDefined()
        expect(TuringEmailApp.views.createFolderView.app).toEqual(TuringEmailApp)

      it "hooks the create folder view createFolderFormSubmitted event", ->
        spy = sinon.spy(TuringEmailApp, "createFolderFormSubmitted")
  
        TuringEmailApp.setupCreateFolderView()
        TuringEmailApp.views.createFolderView.trigger("createFolderFormSubmitted", TuringEmailApp.views.createFolderView, "label", "test label name")

        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith("label", "test label name")
        spy.restore()

    describe "#setupEmailThreads", ->
      it "creates the email threads collection and list view", ->
        TuringEmailApp.setupEmailThreads()
  
        expect(TuringEmailApp.collections.emailThreads).toBeDefined()
        expect(TuringEmailApp.views.emailThreadsListView).toBeDefined()
  
        expect(TuringEmailApp.views.emailThreadsListView.collection).toEqual(TuringEmailApp.collections.emailThreads)
  
      threadsListViewEvents = ["listItemSelected", "listItemDeselected", "listItemChecked", "listItemUnchecked"]
      for event in threadsListViewEvents
        it "hooks the listview " + event + " event", ->
          spy = sinon.spy(TuringEmailApp, event)
  
          TuringEmailApp.setupEmailThreads()
          TuringEmailApp.views.emailThreadsListView.trigger(event)
  
          expect(spy).toHaveBeenCalled()
          spy.restore()
        
    describe "#setupRouters", ->
      it "creates the routers", ->
        TuringEmailApp.setupRouters()
        
        expect(TuringEmailApp.routers.emailFoldersRouter).toBeDefined()
        expect(TuringEmailApp.routers.emailThreadsRouter).toBeDefined()
        expect(TuringEmailApp.routers.analyticsRouter).toBeDefined()
        expect(TuringEmailApp.routers.reportsRouter).toBeDefined()
        expect(TuringEmailApp.routers.settingsRouter).toBeDefined()
        expect(TuringEmailApp.routers.searchResultsRouter).toBeDefined()
        expect(TuringEmailApp.routers.appsLibraryRouter).toBeDefined()
  
  describe "after start", ->
    beforeEach ->
      TuringEmailApp.start(FactoryGirl.create("User"), FactoryGirl.create("UserSettings"))
      TuringEmailApp.showEmails()
      
      @server.restore()
      @server = sinon.fakeServer.create()
      
    describe "getters", ->
      describe "#selectedEmailThread", ->
        beforeEach ->
          emailThreadAttributes = FactoryGirl.create("EmailThread")
          @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes.toJSON(),
            app: TuringEmailApp
            emailThreadUID: emailThreadAttributes.uid
            demoMode: false
          )
    
          TuringEmailApp.views.emailThreadsListView.collection.add(@emailThread)
          TuringEmailApp.views.emailThreadsListView.select(@emailThread)
          
        it "returns the selected email thread", ->
          #expect(TuringEmailApp.selectedEmailThread()).toEqual(@emailThread)
          
      describe "#selectedEmailFolder", ->
        beforeEach ->
          emailFoldersData = FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE)
          @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(emailFoldersData,
            app: TuringEmailApp
            demoMode: false
          )
          
          TuringEmailApp.views.emailFoldersTreeView.select(@emailFolders.models[0])

        it "returns the selected email folder", ->
          expect(TuringEmailApp.selectedEmailFolder()).toEqual(@emailFolders.models[0])

      describe "#selectedEmailFolderID", ->
        beforeEach ->
          @emailFolders = TuringEmailApp.collections.emailFolders
          @emailFolders.add(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))
          TuringEmailApp.views.emailFoldersTreeView.select(@emailFolders.models[0])

        it "returns the selected email folder id", ->
          expect(TuringEmailApp.selectedEmailFolderID()).toEqual(@emailFolders.models[0].get("label_id"))

    describe "setters", ->
      describe "#currentEmailThreadIs", ->
        beforeEach ->
          @loadEmailThreadStub = sinon.spy(TuringEmailApp, "loadEmailThread")
          
          @showEmailThreadStub = sinon.stub(TuringEmailApp, "showEmailThread", ->)
          @selectStub = sinon.stub(TuringEmailApp.views.emailThreadsListView, "select", ->)
          @deselectStub = sinon.stub(TuringEmailApp.views.emailThreadsListView, "deselect", ->)
          @uncheckAllCheckboxStub = sinon.stub(TuringEmailApp.views.toolbarView, "uncheckAllCheckbox", ->)

          @changeSelectedEmailThreadStub = sinon.backbone.spy(TuringEmailApp, "change:selectedEmailThread")

        afterEach ->
          @loadEmailThreadStub.restore()
          
          @showEmailThreadStub.restore()
          @selectStub.restore()
          @deselectStub.restore()
          @uncheckAllCheckboxStub.restore()

          @changeSelectedEmailThreadStub.restore()

        describe "the email thread exists", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.reset(
              _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
                (emailThread) => emailThread.toJSON()
              )
            )
            @emailThread = TuringEmailApp.collections.emailThreads.at(0)
          
          describe "the email thread is currently displayed", ->
            beforeEach ->
              TuringEmailApp.currentEmailThreadView = {model: TuringEmailApp.collections.emailThreads.at(0)}

              TuringEmailApp.currentEmailThreadIs(TuringEmailApp.collections.emailThreads.at(0).get("uid"))
              
            afterEach ->
              TuringEmailApp.currentEmailThreadView = null

            it "does NOT selects the thread", ->
              expect(@selectStub).not.toHaveBeenCalled()

            it "does NOT shows the email thread", ->
              expect(@showEmailThreadStub).not.toHaveBeenCalled()
    
            it "does NOT unchecks all the checkboes", ->
              expect(@uncheckAllCheckboxStub).not.toHaveBeenCalled()
    
            it "does NOT trigger the change:selectedEmailThread event", ->
              expect(@changeSelectedEmailThreadStub).not.toHaveBeenCalled()

          describe "the email thread is not currently displayed", ->
            beforeEach ->
              TuringEmailApp.currentEmailThreadIs(@emailThread.get("uid"))

            it "loads the email thread", ->
              expect(@loadEmailThreadStub).toHaveBeenCalled()              
                
            it "selects the thread", ->
              expect(@selectStub).toHaveBeenCalledWith(@emailThread)
  
            it "shows the email thread", ->
              expect(@showEmailThreadStub).toHaveBeenCalled()
  
            it "unchecks all the checkboes", ->
              expect(@uncheckAllCheckboxStub).toHaveBeenCalled()
  
            it "triggers the change:selectedEmailThread event", ->
              expect(@changeSelectedEmailThreadStub).toHaveBeenCalledWith(TuringEmailApp, @emailThread)

        describe "clear the email thread", ->
          beforeEach ->
            TuringEmailApp.currentEmailThreadIs(".")
          
          it "shows the email thread", ->
            expect(@showEmailThreadStub).toHaveBeenCalled()

          it "deselects the selected thread", ->
            expect(@deselectStub).toHaveBeenCalled()

          it "unchecks all the checkboes", ->
            expect(@uncheckAllCheckboxStub).toHaveBeenCalled()

          it "triggers the change:selectedEmailThread event", ->
            expect(@changeSelectedEmailThreadStub).toHaveBeenCalledWith(TuringEmailApp, null)
          
      describe "#currentEmailFolderIs", ->
        beforeEach ->
          @reloadEmailThreadsStub = sinon.stub(TuringEmailApp, "reloadEmailThreads", ->)
          @emailFoldersTreeViewSelectSpy = sinon.spy(TuringEmailApp.views.emailFoldersTreeView, "select")

          @changecurrentEmailFolderSpy = sinon.backbone.spy(TuringEmailApp, "change:currentEmailFolder")
          
          TuringEmailApp.currentEmailFolderIs("INBOX")

          TuringEmailApp.collections.emailThreads.reset(
            _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
              (emailThread) => emailThread.toJSON()
            )
          )
          
        afterEach ->
          @reloadEmailThreadsStub.restore()
          @emailFoldersTreeViewSelectSpy.restore()

          @changecurrentEmailFolderSpy.restore()
          
        describe "after fetch", ->
          beforeEach ->
            @reloadEmailThreadsStub.args[0][0].success(TuringEmailApp.collections.emailThreads)
  
            @emailFolder = TuringEmailApp.collections.emailFolders.get("INBOX")
          
          it "reloads the email threads", ->
            expect(@reloadEmailThreadsStub).toHaveBeenCalled()
            
          it "selects the email folder on the tree view", ->
            expect(@emailFoldersTreeViewSelectSpy).toHaveBeenCalledWith(@emailFolder, silent: true)
  
          it "triggers the change:currentEmailFolder event", ->
            expect(@changecurrentEmailFolderSpy).toHaveBeenCalledWith(TuringEmailApp, @emailFolder)

        describe "before fetch", ->
          beforeEach ->
            @currentEmailThreadIsStub = sinon.stub(TuringEmailApp, "currentEmailThreadIs", ->)

          afterEach ->
            @currentEmailThreadIsStub.restore()
            
          describe "no draft", ->  
            describe "with split pane", ->
              beforeEach ->
                @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
                TuringEmailApp.isSplitPaneMode = -> return true

                @reloadEmailThreadsStub.args[0][0].success(TuringEmailApp.collections.emailThreads)
                @emailThread = TuringEmailApp.collections.emailThreads.at(0)

              afterEach ->
                TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction

              it "selects an email thread", ->
                expect(@currentEmailThreadIsStub).toHaveBeenCalledWith(@emailThread.get("uid"))

            describe "with NO split pane", ->
              beforeEach ->
                @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
                TuringEmailApp.isSplitPaneMode = -> return false

                @reloadEmailThreadsStub.args[0][0].success(TuringEmailApp.collections.emailThreads)
                @emailThread = TuringEmailApp.collections.emailThreads.at(0)

              afterEach ->
                TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction

              it "does NOT selects an email thread", ->
                expect(@currentEmailThreadIsStub).not.toHaveBeenCalledWith(@emailThread.get("uid"))

          describe "with draft", ->
            beforeEach ->
              TuringEmailApp.collections.emailThreads.at(0).get("emails")[0].draft_id = "1"
              
            describe "with split pane", ->
              beforeEach ->
                @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
                TuringEmailApp.isSplitPaneMode = -> return true

                @reloadEmailThreadsStub.args[0][0].success(TuringEmailApp.collections.emailThreads)
                @emailThread = TuringEmailApp.collections.emailThreads.at(0)

              afterEach ->
                TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction

              it "does NOT selects an email thread", ->
                expect(@currentEmailThreadIsStub).not.toHaveBeenCalledWith(@emailThread.get("uid"))

            describe "with NO split pane", ->
              beforeEach ->
                @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
                TuringEmailApp.isSplitPaneMode = -> return false

                @reloadEmailThreadsStub.args[0][0].success(TuringEmailApp.collections.emailThreads)
                @emailThread = TuringEmailApp.collections.emailThreads.at(0)

              afterEach ->
                TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction

              it "does NOT selects an email thread", ->
                expect(@currentEmailThreadIsStub).not.toHaveBeenCalledWith(@emailThread.get("uid"))

    describe "#syncEmail", ->
      beforeEach ->
        @syncEmailStub.restore()
        
        @reloadEmailThreadsStub = sinon.stub(TuringEmailApp, "reloadEmailThreads")
        @loadEmailFoldersStub = sinon.stub(TuringEmailApp, "loadEmailFolders")
        @setTimeoutStub = sinon.stub(window, "setTimeout", ->)
        
        TuringEmailApp.syncEmail()
        
      afterEach ->
        @reloadEmailThreadsStub.restore()
        @loadEmailFoldersStub.restore()
        @setTimeoutStub.restore()

        @syncEmailStub = sinon.stub(TuringEmailApp, "syncEmail")

      it "reloads the emails threads", ->
        expect(@reloadEmailThreadsStub).toHaveBeenCalled()

      it "reloads the emails folders", ->
        expect(@loadEmailFoldersStub).toHaveBeenCalled()

      it "schedules the next sync", ->
        expect(@setTimeoutStub).toHaveBeenCalled()
        specCompareFunctions((=> @syncEmail()), @setTimeoutStub.args[0][0])
        expect(@setTimeoutStub.args[0][1]).toEqual(60000)
        
      describe "demoMode=true", ->
        beforeEach ->
          @postStub = sinon.stub($, "post", ->)
          TuringEmailApp.models.userSettings.set("demo_mode_enabled", true)
          
          TuringEmailApp.syncEmail()
          
        afterEach ->
          @postStub.restore()
          
        it "posts", ->
          expect(@postStub).toHaveBeenCalledWith("api/v1/email_accounts/sync")

      describe "demoMode=false", ->
        beforeEach ->
          @postStub = sinon.stub($, "post", ->)
          TuringEmailApp.models.userSettings.set("demo_mode_enabled", false)
          
          TuringEmailApp.syncEmail()

        afterEach ->
          @postStub.restore()

        it "does NOT post", ->
          expect(@postStub).not.toHaveBeenCalled()

    describe "Alert Functions", ->
      describe "#showAlert", ->
        beforeEach ->
          @alertText = "test"
          @alertClass = "testAlert"
          @alertSelector = "." + @alertClass

          @removeAlertSpy = sinon.spy(TuringEmailApp, "removeAlert")

          if TuringEmailApp.currentAlert?
            TuringEmailApp.currentAlert.remove()
            TuringEmailApp.currentAlert = undefined

        afterEach ->
          TuringEmailApp.removeAlert(@token)
          @removeAlertSpy.restore()
          
        describe "when there is no current alert", ->
          beforeEach ->
            expect(TuringEmailApp.currentAlert).not.toBeDefined()
            @token = TuringEmailApp.showAlert(@alertText, @alertClass)
            
          it "shows the alert", ->
            expect($(@alertSelector).length).toEqual(1)
            expect($(@alertSelector).text().replace(/(\r\n|\n|\r)/gm,"")).toEqual(@alertText + " (dismiss)")

          it "does not remove an existing alert", ->
            expect(@removeAlertSpy).not.toHaveBeenCalled()

          it "returns the token", ->
            expect(TuringEmailApp.currentAlert.token).toEqual(@token)

          it "adds the dismiss link", ->
            expect($(".dismiss-alert").length).toEqual(1)
            expect($(".dismiss-alert-link").length).toEqual(1)
            expect($(".dismiss-alert-link")).toHandle("click")
            
          it "dismisses the alert when the dismiss alert link is clicked", ->
            $(".dismiss-alert-link").click()
            expect(@removeAlertSpy).toHaveBeenCalledWith(@token)
      
        describe "when an alert is displayed", ->
          beforeEach ->
            TuringEmailApp.showAlert("a", "b")
            @token = TuringEmailApp.showAlert(@alertText, @alertClass)

          it "removes the alert", ->
            expect(@removeAlertSpy).toHaveBeenCalled()
      
      describe "#removeAlert", ->
        beforeEach ->
          @alertText = "test"
          @alertClass = "testAlert"
          @alertSelector = "." + @alertClass
          
          @token = TuringEmailApp.showAlert(@alertText, @alertClass)
          
          @alert = $(@alertSelector)
          
        describe "when the token does not match", ->
          beforeEach ->
            TuringEmailApp.removeAlert(@token + "1")
            
          it "does NOT remove the alert", ->
            expect(@alert).toBeInDOM()
            
        describe "when the token matches", ->
          beforeEach ->
            TuringEmailApp.removeAlert(@token)

          it "removes the alert", ->
            expect(@alert).not.toBeInDOM()
          
    describe "Email Folder Functions", ->
      describe "#loadEmailFolders", ->
        beforeEach ->
          @fetchStub = sinon.spy(TuringEmailApp.collections.emailFolders, "fetch")
          @changeEmailFoldersSpy = sinon.backbone.spy(TuringEmailApp, "change:emailFolders")

          TuringEmailApp.loadEmailFolders()
          
        afterEach ->
          @changeEmailFoldersSpy.restore()
          @fetchStub.restore()
          
        it "fetches the email folders", ->
          expect(@fetchStub).toHaveBeenCalled()

        it "sets the reset option to true", ->
          expect(@fetchStub.args[0][0].reset).toBeTruthy()
          
        describe "after the email folders are fetched", ->
          beforeEach ->
            options = @fetchStub.args[0][0]
            options.success(TuringEmailApp.collections.emailFolders, {}, options)

          it "triggers the change:emailFolders event", ->
            expect(@changeEmailFoldersSpy).toHaveBeenCalledWith(TuringEmailApp, TuringEmailApp.collections.emailFolders)
  
    describe "Email Thread Functions", ->
      describe "#loadEmailThread", ->
        beforeEach ->
          @callback = sinon.spy()

        describe "when the email thread is NOT in the collection", ->
          beforeEach ->
            @fetchStub = sinon.spy(TuringEmailApp.Models.EmailThread.__super__, "fetch")

            emailThreadAttributes = FactoryGirl.create("EmailThread")
            @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
              app: TuringEmailApp
              emailThreadUID: emailThreadAttributes.uid
              demoMode: false
            )

          afterEach ->
            @fetchStub.restore()

          it "fetches the email thread and then calls the callback", ->
            expect(@callback).not.toHaveBeenCalled()
            TuringEmailApp.loadEmailThread(@emailThread.get("uid"), @callback)
            @fetchStub.args[0][0].success(@emailThread, {}, null)
            expect(@callback).toHaveBeenCalled()

        describe "when the email thread is in the collection", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.reset(
              _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
                (emailThread) => emailThread.toJSON()
              )
            )
            TuringEmailApp.loadEmailThread(TuringEmailApp.collections.emailThreads.at(0).get("uid"), @callback)
            
          it "calls the callback", ->
            expect(@callback).toHaveBeenCalled()
      
      describe "#reloadEmailThreads", ->
        beforeEach ->
          @fetchStub = sinon.spy(TuringEmailApp.collections.emailThreads, "fetch")
          
          @success = sinon.stub()
          @error = sinon.stub()
          
        afterEach ->
          @fetchStub.restore()

        it "fetches the email threads", ->
          TuringEmailApp.reloadEmailThreads(success: @success, error: @error)
          expect(@fetchStub).toHaveBeenCalled()

        describe "on success", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.reset(
              _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
                (emailThread) => emailThread.toJSON()
              )
            )
            @oldEmailThreads = TuringEmailApp.collections.emailThreads.models

            @stopListeningSpy = sinon.spy(TuringEmailApp, "stopListening")
            @listenToSpy = sinon.spy(TuringEmailApp, "listenTo")
            @moveTuringEmailReportToTopSpy = sinon.spy(TuringEmailApp, "moveTuringEmailReportToTop")

            @triggerStub = sinon.stub(@oldEmailThreads[0], "trigger")
            TuringEmailApp.views.emailThreadsListView.select(@oldEmailThreads[0])
            @emailThreadsListViewSelectStub = sinon.stub(TuringEmailApp.views.emailThreadsListView, "select", ->)
            
            TuringEmailApp.reloadEmailThreads(success: @success, error: @error)
            TuringEmailApp.collections.emailThreads.reset(_.clone(@oldEmailThreads))

            @response = {}
            @options = previousModels: @oldEmailThreads
            @fetchStub.args[0][0].success(TuringEmailApp.collections.emailThreads, @response, @options)

          afterEach ->
            @stopListeningSpy.restore()
            @listenToSpy.restore()
            @moveTuringEmailReportToTopSpy.restore()
            @emailThreadsListViewSelectStub.restore()
            @triggerStub.restore()

          it "stops listening on the old models", ->
            expect(@stopListeningSpy).toHaveBeenCalledWith(oldEmailThread) for oldEmailThread in @oldEmailThreads

          it "listens for change:seen on the new models", ->
            for emailThread in TuringEmailApp.collections.emailThreads.models
              expect(@listenToSpy).toHaveBeenCalledWith(emailThread, "change:seen", TuringEmailApp.emailThreadSeenChanged)

          it "listens for change:folder on the new models", ->
            for emailThread in TuringEmailApp.collections.emailThreads.models
              expect(@listenToSpy).toHaveBeenCalledWith(emailThread, "change:folder", TuringEmailApp.emailThreadFolderChanged)

          it "moves the Turing email report to the top", ->
            expect(@moveTuringEmailReportToTopSpy).toHaveBeenCalled()
            
          it "selects the previously selected email thread", ->
            emailThreadToSelect = TuringEmailApp.collections.emailThreads.get(@oldEmailThreads[0].get("uid"))
            expect(@emailThreadsListViewSelectStub).toHaveBeenCalledWith(emailThreadToSelect)
              
          it "calls the success callback", ->
            expect(@success).toHaveBeenCalled()

          it "does NOT call the error callback", ->
            expect(@error).not.toHaveBeenCalled()

        describe "on error", ->
          beforeEach ->
            TuringEmailApp.reloadEmailThreads(success: @success, error: @error)
            @fetchStub.args[0][0].error()

          it "does NOT call the success callback", ->
            expect(@success).not.toHaveBeenCalled()

          it "calls the error callback", ->
            expect(@error).toHaveBeenCalled()

      describe "#loadSearchResults", ->
        beforeEach ->
          @reloadEmailThreadsStub = sinon.spy(TuringEmailApp, "reloadEmailThreads")
          @showEmailsStub = sinon.stub(TuringEmailApp, "showEmails", ->)

          @query = "test"
          TuringEmailApp.loadSearchResults(@query)
          
        afterEach ->
          @showEmailsStub.restore()
          @reloadEmailThreadsStub.restore()

        it "reloads the email threads", ->
          expect(@reloadEmailThreadsStub).toHaveBeenCalled()
          
        it "passes on the query", ->
          expect(@reloadEmailThreadsStub.args[0][0].query).toEqual(@query)
          
        describe "on success", ->
          beforeEach ->
            @reloadEmailThreadsStub.args[0][0].success()
            
          it "shows the emails", ->
            expect(@showEmailsStub).toHaveBeenCalled()
            
      describe "#applyActionToSelectedThreads", ->
        beforeEach ->
          @singleAction = sinon.spy()
          @multiAction = sinon.spy()
      
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection
      
          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads
      
        afterEach ->
          @listViewDiv.remove()

        describe "when refreshFolders is true", ->

          it "refreshes the email folders.", ->
            @loadEmailFoldersSpy = sinon.spy(TuringEmailApp, "loadEmailFolders")
            TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true, true, true)
            expect(@loadEmailFoldersSpy).toHaveBeenCalled()
            @loadEmailFoldersSpy.restore()

        describe "clearSelection", ->
          beforeEach ->
            @origisSplitPaneMode = TuringEmailApp.isSplitPaneMode
      
            @currentEmailThreadIsSpy = sinon.spy(TuringEmailApp, "currentEmailThreadIs")
            @goBackClickedSpy = sinon.spy(TuringEmailApp, "goBackClicked")
      
          afterEach ->
            @currentEmailThreadIsSpy.restore()
            @goBackClickedSpy.restore()
      
            TuringEmailApp.isSplitPaneMode = @origisSplitPaneMode
      
          describe "is true", ->
            describe "with split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return true
                TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true, true)
      
              it "clears the current email thread", ->
                expect(@currentEmailThreadIsSpy).toHaveBeenCalledWith()
                expect(@goBackClickedSpy).not.toHaveBeenCalled()
      
            describe "without split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return false
                TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true, true)
      
              it "clears the current email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalled()
                expect(@goBackClickedSpy).toHaveBeenCalled()
      
          describe "is false", ->
            describe "with split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return true
                TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true, false)
      
              it "clears the current email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalled()
                expect(@goBackClickedSpy).not.toHaveBeenCalled()
      
            describe "without split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return false
                TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true, false)
      
              it "clears the current email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalled()
                expect(@goBackClickedSpy).not.toHaveBeenCalled()
      
        describe "when an item is selected", ->
          beforeEach ->
            @emailThread = @emailThreads.models[0]
            @listView.select(@emailThread)
      
          describe "when remove is true", ->
            beforeEach ->
              TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true)
      
            it "calls the single action", ->
              expect(@singleAction).toHaveBeenCalled()
      
            it "does NOT call the multi action", ->
              expect(@multiAction).not.toHaveBeenCalled()
      
            it "removes the item", ->
              expect(@emailThreads.findWhere(uid: @emailThread.uid)).toBeFalsy()
      
          describe "when remove is false", ->
            beforeEach ->
              TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, false)
      
            it "calls the single action", ->
              expect(@singleAction).toHaveBeenCalled()
      
            it "does NOT call the multi action", ->
              expect(@multiAction).not.toHaveBeenCalled()
      
            it "removes the item", ->
              expect(@emailThreads.findWhere(uid: @emailThread.uid)).toBeUndefined()
      
        describe "when an item is checked", ->
          beforeEach ->
            @emailThread = @emailThreads.models[0]
            @emailThreadUID = @emailThread.get("uid")
            @listItemView = @listView.listItemViews[@emailThreadUID]
            @listView.check(@emailThread)
      
          describe "when remove is true", ->
            beforeEach ->
              TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true)
      
            it "does NOT call the single action", ->
              expect(@singleAction).not.toHaveBeenCalled()
      
            it "calls the multi action", ->
              expect(@multiAction).toHaveBeenCalledWith([@listItemView], [@emailThreadUID])
      
            it "removes the item", ->
              expect(@emailThreads.findWhere(uid: @emailThread.uid)).toBeFalsy()
      
          describe "when remove is false", ->
            beforeEach ->
              TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, false)
      
            it "does NOT call the single action", ->
              expect(@singleAction).not.toHaveBeenCalled()
      
            it "calls the multi action", ->
              expect(@multiAction).toHaveBeenCalledWith([@listItemView], [@emailThreadUID])
      
            it "removes the item", ->
              expect(@emailThreads.findWhere(uid: @emailThread.uid)).toBeUndefined()

    describe "General Events", ->
      describe "#checkAllClicked", ->
        beforeEach ->
          @spy = sinon.spy(TuringEmailApp.views.emailThreadsListView, "checkAll")
          TuringEmailApp.checkAllClicked()
  
        afterEach ->
          @spy.restore()
  
        it "checks all the items in the email threads list view", ->
          expect(@spy).toHaveBeenCalled()
          
      describe "#checkAllReadClicked", ->
        beforeEach ->
          @spy = sinon.spy(TuringEmailApp.views.emailThreadsListView, "checkAllRead")
          TuringEmailApp.checkAllReadClicked()

        afterEach ->
          @spy.restore()

        it "checks all the read items in the email threads list view", ->
          expect(@spy).toHaveBeenCalled()

      describe "#checkAllUnreadClicked", ->
        beforeEach ->
          @spy = sinon.spy(TuringEmailApp.views.emailThreadsListView, "checkAllUnread")
          TuringEmailApp.checkAllUnreadClicked()

        afterEach ->
          @spy.restore()

        it "checks all the unread items in the email threads list view", ->
          expect(@spy).toHaveBeenCalled()

      describe "#uncheckAllClicked", ->
        beforeEach ->
          @spy = sinon.spy(TuringEmailApp.views.emailThreadsListView, "uncheckAll")
          TuringEmailApp.uncheckAllClicked()

        afterEach ->
          @spy.restore()

        it "unchecks all items in the email threads list view", ->
          expect(@spy).toHaveBeenCalled()
          
      describe "#readClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection
  
          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads
          
          @emailThread = @emailThreads.models[0]
          
        afterEach ->
          @listViewDiv.remove()
          
        describe "when an email thread is selected", ->
          beforeEach ->
            @listView.select(@emailThread)
            
            @setStub = sinon.stub(@emailThread, "set", ->)
            
            TuringEmailApp.readClicked()
          
          afterEach ->
            @setStub.restore()
            
          it "sets the email thread to read", ->
            expect(@setStub).toHaveBeenCalledWith("seen", true)
            
        describe "when an email thread is checked", ->
          beforeEach ->
            @listView.check(@emailThread)

            @setStub = sinon.stub(@emailThread, "set", ->)

            TuringEmailApp.readClicked()

          afterEach ->
            @setStub.restore()

          it "sets the email thread to read", ->
            expect(@setStub).toHaveBeenCalledWith("seen", true)

      describe "#unreadClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @listView.select(@emailThread)

            @setStub = sinon.stub(@emailThread, "set", ->)

            TuringEmailApp.unreadClicked()

          afterEach ->
            @setStub.restore()

          it "sets the email thread to unread", ->
            expect(@setStub).toHaveBeenCalledWith("seen", false)

        describe "when an email thread is checked", ->
          beforeEach ->
            @listView.check(@emailThread)

            @setStub = sinon.stub(@emailThread, "set", ->)

            TuringEmailApp.unreadClicked()

          afterEach ->
            @setStub.restore()

          it "sets the email thread to unread", ->
            expect(@setStub).toHaveBeenCalledWith("seen", false)
            
      describe "#leftArrowClicked", ->
        beforeEach ->
          TuringEmailApp.collections.emailThreads.reset(
            _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
            )
          )
          
          @hasPreviousPageStub = sinon.stub(TuringEmailApp.collections.emailThreads, "hasPreviousPage")
          
          @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
          @folderID = "test"
          @selectedEmailFolderIDStub.returns(@folderID)

          @navigateStub = sinon.stub(TuringEmailApp.routers.emailFoldersRouter, "navigate")
          
        afterEach ->
          @hasPreviousPageStub.restore()
          @selectedEmailFolderIDStub.restore()
          @navigateStub.restore()

        describe "has a previous page", ->
          beforeEach ->
            @hasPreviousPageStub.returns(true)
          
          describe "demoMode=true", ->
            beforeEach ->
              TuringEmailApp.models.userSettings.set("demo_mode_enabled", true)
              TuringEmailApp.leftArrowClicked()
            
            it "goes to the previous page", ->
              url = "#email_folder/" + @folderID +
                    "/" + (TuringEmailApp.collections.emailThreads.pageTokenIndex - 1) +
                    "/" + TuringEmailApp.collections.emailThreads.at(0).get("uid") +
                    "/ASC"
              expect(@navigateStub).toHaveBeenCalledWith(url, trigger: true)

          describe "demoMode=false", ->
            beforeEach ->
              TuringEmailApp.models.userSettings.set("demo_mode_enabled", false)
              TuringEmailApp.leftArrowClicked()

            it "goes to the previous page", ->
              url = "#email_folder/" + @folderID +
                    "/" + (TuringEmailApp.collections.emailThreads.pageTokenIndex - 1)
              expect(@navigateStub).toHaveBeenCalledWith(url, trigger: true)

        describe "does NOT have a previous page", ->
          beforeEach ->
            @hasPreviousPageStub.returns(false)
            TuringEmailApp.leftArrowClicked()

          it "does NOT go to the previous page", ->
            expect(@navigateStub).not.toHaveBeenCalled()

      describe "#rightArrowClicked", ->
        beforeEach ->
          TuringEmailApp.collections.emailThreads.reset(
            _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
            )
          )
          
          @hasNextPageStub = sinon.stub(TuringEmailApp.collections.emailThreads, "hasNextPage")

          @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
          @folderID = "test"
          @selectedEmailFolderIDStub.returns(@folderID)

          @navigateStub = sinon.stub(TuringEmailApp.routers.emailFoldersRouter, "navigate")

        afterEach ->
          @hasNextPageStub.restore()
          @selectedEmailFolderIDStub.restore()
          @navigateStub.restore()

        describe "has a next page", ->
          beforeEach ->
            @hasNextPageStub.returns(true)
            
          describe "demoMode=true", ->
            beforeEach ->
              TuringEmailApp.models.userSettings.set("demo_mode_enabled", true)              
              TuringEmailApp.rightArrowClicked()

            it "goes to the next page", ->
              url = "#email_folder/" + @folderID +
                    "/" + (TuringEmailApp.collections.emailThreads.pageTokenIndex + 1) +
                    "/" + TuringEmailApp.collections.emailThreads.last().get("uid") +
                    "/DESC"
              expect(@navigateStub).toHaveBeenCalledWith(url, trigger: true)

          describe "demoMode=false", ->
            beforeEach ->
              TuringEmailApp.models.userSettings.set("demo_mode_enabled", false)
              TuringEmailApp.rightArrowClicked()

            it "goes to the next page", ->
              url = "#email_folder/" + @folderID +
                    "/" + (TuringEmailApp.collections.emailThreads.pageTokenIndex + 1)
              expect(@navigateStub).toHaveBeenCalledWith(url, trigger: true)

        describe "does NOT have a next page", ->
          beforeEach ->
            @hasNextPageStub.returns(false)
            TuringEmailApp.rightArrowClicked()

          it "does NOT go to the next page", ->
            expect(@navigateStub).not.toHaveBeenCalled()

      describe "#labelAsClicked", ->
        beforeEach ->
          @server.restore()
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @applyGmailLabelStub = sinon.stub(@emailThread, "applyGmailLabel")

            @listView.select(@emailThread)

            @labelID = "test"
            TuringEmailApp.labelAsClicked(@labelID)

          afterEach ->
            @applyGmailLabelStub.restore()

          it "applies the label to the selected email thread", ->
            expect(@applyGmailLabelStub).toHaveBeenCalledWith(@labelID)

        describe "when an email thread is checked", ->
          beforeEach ->
            @applyGmailLabelStub = sinon.stub(TuringEmailApp.Models.EmailThread, "applyGmailLabel")

            @listView.check(@emailThread)

            @labelID = "test"
            TuringEmailApp.labelAsClicked(@labelID)

          afterEach ->
            @applyGmailLabelStub.restore()

          it "applies the label to the checked email threads", ->
            expect(@applyGmailLabelStub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")], @labelID)

      describe "#moveToFolderClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @moveToFolderStub = sinon.stub(@emailThread, "moveToFolder")

            @listView.select(@emailThread)

            @folderID = "test"
            TuringEmailApp.moveToFolderClicked(@folderID)

          afterEach ->
            @moveToFolderStub.restore()

          it "moves the selected email thread to the folder", ->
            expect(@moveToFolderStub).toHaveBeenCalledWith(@folderID)

        describe "when an email thread is checked", ->
          beforeEach ->
            @moveToFolderStub = sinon.stub(@emailThread, "moveToFolder")

            @listView.check(@emailThread)

            @folderID = "test"
            TuringEmailApp.moveToFolderClicked(@folderID)

          afterEach ->
            @moveToFolderStub.restore()

          it "moves the checked email threads to the folder", ->
            expect(@moveToFolderStub).toHaveBeenCalledWith(@folderID)

      describe "#refreshClicked", ->

        it "reloads the email threads", ->
          spy = sinon.spy(TuringEmailApp, "reloadEmailThreads")
          TuringEmailApp.refreshClicked()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "#searchClicked", ->

        it "navigates to perform the search with the query", ->
          seededChance = new Chance(1)
          randomSearchQuery = seededChance.string({length: 10})
          spy = sinon.spy(TuringEmailApp.routers.searchResultsRouter, "navigate")
          TuringEmailApp.searchClicked(randomSearchQuery)
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith("#search/" + randomSearchQuery)
          spy.restore()

      describe "#goBackClicked", ->
        beforeEach ->
          @selectedEmailFolderIDFunction = TuringEmailApp.selectedEmailFolderID
          TuringEmailApp.selectedEmailFolderID = -> return "test"

        afterEach ->
          TuringEmailApp.selectedEmailFolderID = @selectedEmailFolderIDFunction

        it "shows the selected email folder", ->
          spy = sinon.spy(TuringEmailApp.routers.emailFoldersRouter, "showFolder")
          TuringEmailApp.goBackClicked()
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith("test")
          spy.restore()

      describe "#replyClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection
    
          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = _.values(@listView.listItemViews)[0].model

          TuringEmailApp.views.emailThreadsListView.select @emailThread

          @showEmailEditorWithEmailThreadStub = sinon.stub(TuringEmailApp, "showEmailEditorWithEmailThread", ->)
          
        afterEach ->
          @showEmailEditorWithEmailThreadStub.restore()

        it "shows the email editor with the selected email thread", ->
          TuringEmailApp.replyClicked()
          expect(@showEmailEditorWithEmailThreadStub).toHaveBeenCalledWith(@emailThread.get("uid"), "reply")

      describe "#forwardClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection
    
          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = _.values(@listView.listItemViews)[0].model

          TuringEmailApp.views.emailThreadsListView.select @emailThread

          @showEmailEditorWithEmailThreadStub = sinon.stub(TuringEmailApp, "showEmailEditorWithEmailThread", ->)

        afterEach ->
          @showEmailEditorWithEmailThreadStub.restore()

        it "shows the email editor with the selected email thread", ->
          TuringEmailApp.forwardClicked()
          expect(@showEmailEditorWithEmailThreadStub).toHaveBeenCalledWith(@emailThread.get("uid"), "forward")
        
      describe "#archiveClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

          @origSelectedEmailFolderID = TuringEmailApp.selectedEmailFolderID
          @folderID = "test"
          TuringEmailApp.selectedEmailFolderID = => @folderID

        afterEach ->
          TuringEmailApp.selectedEmailFolderID = => @origSelectedEmailFolderID
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @removeFromFolderStub = sinon.stub(@emailThread, "removeFromFolder")

            @listView.select(@emailThread)

            @folderID = "test"
            TuringEmailApp.archiveClicked(@folderID)

          afterEach ->
            @removeFromFolderStub.restore()

          it "remove the selected email thread from the selected folder", ->
            expect(@removeFromFolderStub).toHaveBeenCalledWith(@folderID)

        describe "when an email thread is checked", ->
          beforeEach ->
            @removeFromFolderStub = sinon.stub(TuringEmailApp.Models.EmailThread, "removeFromFolder")

            @listView.check(@emailThread)

            @folderID = "test"
            TuringEmailApp.archiveClicked()

          afterEach ->
            @removeFromFolderStub.restore()

          it "removed the checked email threads from the selected folder", ->
            expect(@removeFromFolderStub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")], @folderID)

      describe "#trashClicked", ->
        beforeEach ->
          @listView = specCreateEmailThreadsListView()
          @listViewDiv = @listView.$el
          @emailThreads = @listView.collection

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

          @origSelectedEmailFolderID = TuringEmailApp.selectedEmailFolderID
          @folderID = "test"
          TuringEmailApp.selectedEmailFolderID = => @folderID

        afterEach ->
          TuringEmailApp.selectedEmailFolderID = => @origSelectedEmailFolderID
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @trashStub = sinon.stub(@emailThread, "trash")

            @listView.select(@emailThread)

            @folderID = "test"
            TuringEmailApp.trashClicked(@folderID)

          afterEach ->
            @trashStub.restore()

          it "trash the selected email", ->
            expect(@trashStub).toHaveBeenCalled()

        describe "when an email thread is checked", ->
          beforeEach ->
            @trashStub = sinon.stub(TuringEmailApp.Models.EmailThread, "trash")

            @listView.check(@emailThread)

            @folderID = "test"
            TuringEmailApp.trashClicked()

          afterEach ->
            @trashStub.restore()

          it "trash the checked email threads", ->
            expect(@trashStub).toHaveBeenCalledWith(TuringEmailApp, [@emailThread.get("uid")])

      describe "#createNewLabelClicked", ->
        beforeEach ->
          @showStub = sinon.stub(TuringEmailApp.views.createFolderView, "show")
          
          TuringEmailApp.createNewLabelClicked()
          
        afterEach ->
          @showStub.restore()

        it "shows the create label view", ->
          expect(@showStub).toHaveBeenCalledWith("label")

      describe "#createNewEmailFolderClicked", ->
        beforeEach ->
          @showStub = sinon.stub(TuringEmailApp.views.createFolderView, "show")

          TuringEmailApp.createNewEmailFolderClicked()

        afterEach ->
          @showStub.restore()
          
        it "shows the create folder view", ->
          expect(@showStub).toHaveBeenCalledWith("folder")
        
      describe "#demoModeSwitchClicked", ->
        beforeEach ->
          @token = {}
          
          @setStub = sinon.stub(TuringEmailApp.models.userSettings, "set")
          @showAlertStub = sinon.stub(TuringEmailApp, "showAlert", => @token)
          @saveStub = sinon.stub(TuringEmailApp.models.userSettings, "save")

          TuringEmailApp.demoModeSwitchClicked(true)
          
        afterEach ->
          @setStub.restore()
          @showAlertStub.restore()
          @saveStub.restore()
          
        it "updates demo_mode_enabled", ->
          expect(@setStub).toHaveBeenCalledWith("demo_mode_enabled", true)
          
        it "shows the changing alert", ->
          expect(@showAlertStub).toHaveBeenCalledWith("Changing mode... just a minute please", "alert-success")
          
        it "saves with patch", ->
          expect(@saveStub.args[0][1].patch).toBeTruthy()
          
        describe "on success", ->
          beforeEach ->
            @clock = sinon.useFakeTimers()
            @setTimeoutSpy = sinon.spy(window, "setTimeout")
            @removeAlertStub = sinon.stub(TuringEmailApp, "removeAlert", ->)
            
            @showAlertStub.restore()
            @showAlertStub = sinon.stub(TuringEmailApp, "showAlert", => @token)
            
            @saveStub.args[0][1].success()
          
          afterEach ->
            @clock.restore()
            @setTimeoutSpy.restore()
            @removeAlertStub.restore()
            
          it "shows the alert", ->
            expect(@showAlertStub).toHaveBeenCalled()

          it "queues the remove", ->
            expect(@setTimeoutSpy.args[0][1]).toEqual(15000)

          it "removes the alert after 15 seconds", ->
            @clock.tick(14999)
            expect(@removeAlertStub).not.toHaveBeenCalled()
            @clock.tick(1)
            expect(@removeAlertStub).toHaveBeenCalledWith(@token)

      describe "#installAppClicked", ->
        beforeEach ->
          @installStub = sinon.stub(TuringEmailApp.Models.App, "Install")
          @userSettingsFetchStub = sinon.stub(TuringEmailApp.models.userSettings, "fetch")
          
          @appID = "1"
          TuringEmailApp.installAppClicked(undefined, @appID)
          
        afterEach ->
          @userSettingsFetchStub.restore()
          @installStub.restore()
          
        it "installs the app", ->
          expect(@installStub).toHaveBeenCalledWith(@appID)
          
        it "refreshes the user settings", ->
          expect(@userSettingsFetchStub).toHaveBeenCalledWith(reset: true)

      describe "#uninstallAppClicked", ->
        beforeEach ->
          @uninstallStub = sinon.stub(TuringEmailApp.Models.InstalledApps.InstalledApp, "Uninstall")
          @userSettingsFetchStub = sinon.stub(TuringEmailApp.models.userSettings, "fetch")

          @appID = "1"
          TuringEmailApp.uninstallAppClicked(undefined, @appID)

        afterEach ->
          @userSettingsFetchStub.restore()
          @uninstallStub.restore()

        it "installs the app", ->
          expect(@uninstallStub).toHaveBeenCalledWith(@appID)

        it "refreshes the user settings", ->
          expect(@userSettingsFetchStub).toHaveBeenCalledWith(reset: true)
          
    describe "#listItemSelected", ->
      beforeEach ->
        @listView = specCreateEmailThreadsListView()
        @listViewDiv = @listView.$el
        @emailThreads = @listView.collection
  
        TuringEmailApp.views.emailThreadsListView = @listView
        TuringEmailApp.collections.emailThreads = @emailThreads
  
        @listItemView = _.values(@listView.listItemViews)[0]

        @emailThreadUID = @listItemView.model.get("uid")

        @navigateStub = sinon.stub(TuringEmailApp.routers.emailThreadsRouter, "navigate")
  
      afterEach ->
        @listViewDiv.remove()
        @navigateStub.restore()

      it "navigates to the email thread", ->
        TuringEmailApp.listItemSelected @listView, @listItemView

        expect(@navigateStub).toHaveBeenCalledWith("#email_thread/" +  @emailThreadUID)
  
    describe "#listItemDeselected", ->
      it "navigates to the email thread url", ->
        spy = sinon.spy(TuringEmailApp.routers.emailThreadsRouter, "navigate")
        TuringEmailApp.listItemDeselected null, null
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith("#email_thread/.")
        spy.restore()
  
    describe "#listItemChecked", ->
  
      beforeEach ->
        TuringEmailApp.collections.emailThreads.reset(
          _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
          )
        )
        emailThread = TuringEmailApp.collections.emailThreads.at(0)
        @setStub = sinon.stub(emailThread, "set")
        TuringEmailApp.showEmailThread emailThread
  
      afterEach ->
        @setStub.restore()
        
      it "hides the current email thread view.", ->
        spy = sinon.spy(TuringEmailApp.currentEmailThreadView.$el, "hide")
        TuringEmailApp.listItemChecked null, null
        expect(spy).toHaveBeenCalled()
        spy.restore()
  
    describe "#listItemUnchecked", ->
  
      describe "when there is a current email thread view", ->
        beforeEach ->
          TuringEmailApp.collections.emailThreads.reset(
            _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
              (emailThread) => emailThread.toJSON()
            )
          )
          emailThread = TuringEmailApp.collections.emailThreads.at(0)
          @setStub = sinon.stub(emailThread, "set")
          TuringEmailApp.showEmailThread emailThread
  
        afterEach ->
          @setStub.restore()
  
        describe "when the number of check list items is not 0", ->
  
          beforeEach ->
            @getCheckedListItemViewsFunction = TuringEmailApp.getCheckedListItemViews
            TuringEmailApp.views.emailThreadsListView.getCheckedListItemViews = -> return {"length" : 1}
  
          afterEach ->
            TuringEmailApp.getCheckedListItemViews = @getCheckedListItemViewsFunction
  
          it "does not shows the current email thread view", ->
            spy = sinon.spy(TuringEmailApp.currentEmailThreadView.$el, "show")
            TuringEmailApp.listItemUnchecked null, null
            expect(spy).not.toHaveBeenCalled()
            spy.restore()
  
        describe "when the number of check list items is 0 and there is a current email thread view", ->
  
          beforeEach ->
            @getCheckedListItemViewsFunction = TuringEmailApp.getCheckedListItemViews
            TuringEmailApp.views.emailThreadsListView.getCheckedListItemViews = -> return {"length" : 0}
  
          afterEach ->
            TuringEmailApp.getCheckedListItemViews = @getCheckedListItemViewsFunction
  
          it "shows the current email thread view", ->
            spy = sinon.spy(TuringEmailApp.currentEmailThreadView.$el, "show")
            TuringEmailApp.listItemUnchecked null, null
            expect(spy).toHaveBeenCalled()
            spy.restore()
  
    describe "#emailFolderSelected", ->
  
      describe "when the email folder is defined", ->
        beforeEach ->
          @emailFolder = new TuringEmailApp.Models.EmailFolder()
  
        describe "when the window location is already set to show the email folder page", ->
          beforeEach ->
            TuringEmailApp.routers.emailThreadsRouter.navigate("#email_folder/INBOX", trigger: true)
            @emailFolder.set("label_id", "INBOX")
  
          it "navigates to the email folder url", ->
            spy = sinon.spy(TuringEmailApp.routers.emailFoldersRouter, "showFolder")
            TuringEmailApp.emailFolderSelected null, @emailFolder
            expect(spy).toHaveBeenCalledWith(@emailFolder.get("label_id"))
            spy.restore()
  
        describe "when the window location is not already set to show the email folder page", ->
          beforeEach ->
            @emailFolder.set("label_id", "Label_45")
  
          it "navigates to the email folder url", ->
            spy = sinon.spy(TuringEmailApp.routers.emailFoldersRouter, "navigate")
            TuringEmailApp.emailFolderSelected null, @emailFolder
            expect(spy).toHaveBeenCalledWith("#email_folder/" + @emailFolder.get("label_id"))
            spy.restore()
  
    describe "#draftChanged", ->
      beforeEach ->
        @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
        @selectedEmailFolderIDStub.returns("INBOX")
        
        @reloadEmailThreadsStub = sinon.stub(TuringEmailApp, "reloadEmailThreads")
        @loadEmailFoldersStub = sinon.stub(TuringEmailApp, "loadEmailFolders")

        @draft = new TuringEmailApp.Models.EmailDraft()

        TuringEmailApp.collections.emailThreads.reset(
          _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
          )
        )
        @emailThreadParent = TuringEmailApp.collections.emailThreads.at(0)
        
        @setStub = sinon.stub(@emailThreadParent, "set", ->)
        TuringEmailApp.draftChanged(TuringEmailApp.views.composeView, @draft, @emailThreadParent)
      
      afterEach ->
        @selectedEmailFolderIDStub.restore()
        @reloadEmailThreadsStub.restore()
        @loadEmailFoldersStub.restore()
        @setStub.restore()

      it "reloads the email threads", ->
        expect(@reloadEmailThreadsStub).toHaveBeenCalled()

      it "reloads the email folders", ->
        expect(@loadEmailFoldersStub).toHaveBeenCalled()
        
      it "updates the emailThreadParent", ->
        expect(@setStub).toHaveBeenCalledWith("emails")

    describe "#createFolderFormSubmitted", ->
      beforeEach ->
        seededChance = new Chance(1)
        @randomFolderName = seededChance.string({length: 20})

      describe "when the mode is label", ->

        it "calls labels as clicked with the label name", ->
          spy = sinon.spy(TuringEmailApp, "labelAsClicked")
          TuringEmailApp.createFolderFormSubmitted("label", @randomFolderName)
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(undefined, @randomFolderName)
          spy.restore()

      describe "when the mode is folder", ->

        it "calls move to folder clicked with the folder name", ->
          spy = sinon.spy(TuringEmailApp, "moveToFolderClicked")
          TuringEmailApp.createFolderFormSubmitted("folder", @randomFolderName)
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(undefined, @randomFolderName)
          spy.restore()

    describe "#emailThreadSeenChanged", ->
      beforeEach ->
        TuringEmailApp.collections.emailThreads.reset(
          _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
          )
        )
        TuringEmailApp.collections.emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))
        
        @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
        @selectedEmailFolderIDStub.returns("INBOX")
        
        @emailThread = TuringEmailApp.collections.emailThreads.at(0)
        @emailThread.set("folder_ids", [TuringEmailApp.collections.emailFolders.at(0).get("label_id")])

        folderIDs = @emailThread.get("folder_ids")
        expect(folderIDs.length > 0).toBeTruthy()

        @unreadCounts = {}
        for folderID in @emailThread.get("folder_ids")
          folder = TuringEmailApp.collections.emailFolders.get(folderID)
          @unreadCounts[folderID] = folder.get("num_unread_threads") 
  
      afterEach ->
        @selectedEmailFolderIDStub.restore()
  
      it "triggers a change:emailFolderUnreadCount event", ->
        spy = sinon.backbone.spy(TuringEmailApp, "change:emailFolderUnreadCount")

        TuringEmailApp.emailThreadSeenChanged @emailThread, true

        for folderID in @emailThread.get("folder_ids")
          folder = TuringEmailApp.collections.emailFolders.get(folderID)
          expect(spy).toHaveBeenCalledWith(TuringEmailApp, folder)

        spy.restore()
          
      describe "seenValue=true", ->
        beforeEach ->
          TuringEmailApp.emailThreadSeenChanged @emailThread, true
          
        it "decrements the unread count", ->
          for folderID in @emailThread.get("folder_ids")
            folder = TuringEmailApp.collections.emailFolders.get(folderID)
            expect(folder.get("num_unread_threads")).toEqual(@unreadCounts[folderID] - 1)

      describe "seenValue=false", ->
        beforeEach ->
          TuringEmailApp.emailThreadSeenChanged @emailThread, false

        it "increments the unread count", ->
          for folderID in @emailThread.get("folder_ids")
            folder = TuringEmailApp.collections.emailFolders.get(folderID)
            expect(folder.get("num_unread_threads")).toEqual(@unreadCounts[folderID] + 1)

    describe "#emailThreadFolderChanged", ->

      describe "when the folder is not already in the collection", ->
        beforeEach ->
          @getStub = sinon.stub(TuringEmailApp.collections.emailFolders, "get")
          @getStub.returns(null)

        afterEach ->
          @getStub.restore()

        it "it reloads the email folders", ->
          spy = sinon.spy(TuringEmailApp, "loadEmailFolders")
          TuringEmailApp.emailThreadFolderChanged undefined, {"label_id" : "INBOX"}
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when the folder is already in the collection", ->
        beforeEach ->
          @getStub = sinon.stub(TuringEmailApp.collections.emailFolders, "get")
          @getStub.returns({})

        afterEach ->
          @getStub.restore()

        it "it reloads the email folders", ->
          spy = sinon.spy(TuringEmailApp, "loadEmailFolders")
          TuringEmailApp.emailThreadFolderChanged undefined, {"label_id" : "INBOX"}
          expect(spy).not.toHaveBeenCalled()
          spy.restore()

    describe "#isSplitPaneMode", ->
      beforeEach ->
        TuringEmailApp.models.userSettings = new TuringEmailApp.Models.UserSettings(FactoryGirl.create("UserSettings"))
    
      describe "when split pane mode is horizontal in the user settings", ->
        beforeEach ->
          TuringEmailApp.models.userSettings.attributes.split_pane_mode = "horizontal"
    
        it "should return true", ->
          expect(TuringEmailApp.isSplitPaneMode()).toBeTruthy()
    
      describe "when split pane mode is vertical in the user settings", ->
        beforeEach ->
          TuringEmailApp.models.userSettings.attributes.split_pane_mode = "vertical"
    
        it "should return true", ->
          expect(TuringEmailApp.isSplitPaneMode()).toBeTruthy()
    
      describe "when split pane mode is off in the user settings", ->
        beforeEach ->
          TuringEmailApp.models.userSettings.attributes.split_pane_mode = "off"

        it "should return false", ->
          expect(TuringEmailApp.isSplitPaneMode()).toBeFalsy()
      
    describe "#showEmailThread", ->
      beforeEach ->
        TuringEmailApp.collections.emailThreads.reset(
          _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
          )
        )
        @emailThread = TuringEmailApp.collections.emailThreads.at(0)
        
        @setStub = sinon.stub(@emailThread, "set")
        @eventSpy = null

      afterEach ->
        @eventSpy.restore() if @eventSpy?
        @setStub.restore()
    
      emailThreadViewEvents = ["goBackClicked", "replyClicked", "forwardClicked", "archiveClicked", "trashClicked"]
      for event in emailThreadViewEvents
        it "hooks the emailThreadView " + event + " event", ->
          @eventSpy = sinon.spy(TuringEmailApp, event)
    
          TuringEmailApp.showEmailThread(@emailThread)
          TuringEmailApp.currentEmailThreadView.trigger(event)

          expect(@eventSpy).toHaveBeenCalled()

      describe "when the current email Thread is not null", ->
        beforeEach ->
          TuringEmailApp.showEmailThread(@emailThread)
          @appSpy = sinon.spy(TuringEmailApp, "stopListening")
          @viewSpy = sinon.spy(TuringEmailApp.currentEmailThreadView, "stopListening")
          
        afterEach ->
          @appSpy.restore()
          @viewSpy.restore()

        it "stops listening to the current email thread view", ->
          TuringEmailApp.showEmailThread(@emailThread)
          expect(@appSpy).toHaveBeenCalled()
          expect(@viewSpy).toHaveBeenCalled()

    describe "#showEmailEditorWithEmailThread", ->
      beforeEach ->
        TuringEmailApp.collections.emailThreads.reset(
          _.map(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE),
            (emailThread) => emailThread.toJSON()
          )
        )

        @emailThread = TuringEmailApp.collections.emailThreads.at(0)
        @setStub = sinon.stub(@emailThread, "set")
        
        @email = _.last(@emailThread.get("emails"))
        
      afterEach ->
        @setStub.restore()
    
      it "loads the email thread", ->
        spy = sinon.spy(TuringEmailApp, "loadEmailThread")
        TuringEmailApp.showEmailEditorWithEmailThread @emailThread.get("uid")
        expect(spy).toHaveBeenCalledWith(@emailThread.get("uid"))
        spy.restore()
    
      it "shows the compose view", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "show")
        TuringEmailApp.showEmailEditorWithEmailThread @emailThread.get("uid")
        expect(spy).toHaveBeenCalled()
        spy.restore()
    
      describe "when in draft mode", ->
    
        it "loads the email draft", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailDraft")
          TuringEmailApp.showEmailEditorWithEmailThread @emailThread.get("uid")
          expect(spy).toHaveBeenCalledWith(@email, @emailThread)
          spy.restore()
    
      describe "when in forward mode", ->
    
        it "loads the email as a forward", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailAsForward")
          TuringEmailApp.showEmailEditorWithEmailThread @emailThread.get("uid"), "forward"
          expect(spy).toHaveBeenCalledWith(@email, @emailThread)
          spy.restore()
    
      describe "when in reply mode", ->
    
        it "loads the email as a reply", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailAsReply")
          TuringEmailApp.showEmailEditorWithEmailThread @emailThread.get("uid"), "reply"
          expect(spy).toHaveBeenCalledWith(@email, @emailThread)
          spy.restore()

    describe "#moveTuringEmailReportToTop", ->
      beforeEach ->
        @listView = specCreateEmailThreadsListView()
        @listViewDiv = @listView.$el
        @emailThreads = @listView.collection
        
        TuringEmailApp.views.emailThreadsListView = @listView

        @moveItemToTopStub = sinon.stub(TuringEmailApp.views.emailThreadsListView, "moveItemToTop")
  
      afterEach ->
        @server.restore()
        @listViewDiv.remove()
        @moveItemToTopStub.restore()

      describe "if there is not a report email", ->
        beforeEach ->
          TuringEmailApp.moveTuringEmailReportToTop(TuringEmailApp.views.emailThreadsListView)
          
        it "should leave the emails in the same order", ->
          expect(@moveItemToTopStub).not.toHaveBeenCalled()

      describe "if there is a report email", ->
        beforeEach ->
          @turingEmailThread = _.values(TuringEmailApp.views.emailThreadsListView.listItemViews)[0].model

          TuringEmailApp.views.emailThreadsListView.collection.remove @turingEmailThread
          @turingEmailThread.set("subject", "Turing Email - Your daily Brain Report!")
          TuringEmailApp.views.emailThreadsListView.collection.add @turingEmailThread
          TuringEmailApp.views.emailThreadsListView.render()

          TuringEmailApp.moveTuringEmailReportToTop(TuringEmailApp.views.emailThreadsListView)

        it "should move the email to the top", ->
          expect(@moveItemToTopStub).toHaveBeenCalledWith(@turingEmailThread)

    describe "#showEmails", ->
      beforeEach ->
        @showEmailsSpy = sinon.spy(TuringEmailApp.views.mainView, "showEmails")
        
        TuringEmailApp.showEmails()
        
      afterEach ->
        @showEmailsSpy.restore()
        
      it "shows the emails on the main view", ->
        expect(@showEmailsSpy).toHaveBeenCalledWith(TuringEmailApp.isSplitPaneMode())

    describe "#showAppsLibrary", ->
      beforeEach ->
        @oldAppsLibraryView = TuringEmailApp.appsLibraryView = {}
        
        @appsLibraryView = {}
        @showAppsLibraryStub = sinon.stub(TuringEmailApp.views.mainView, "showAppsLibrary", => @appsLibraryView)
        @listenToStub = sinon.stub(TuringEmailApp, "listenTo", ->)
        @stopListeningStub = sinon.stub(TuringEmailApp, "stopListening", ->)

        TuringEmailApp.showAppsLibrary()
      
      afterEach ->
        @stopListeningStub.restore()
        @listenToStub.restore()
        @showAppsLibraryStub.restore()

      it "shows the apps library on the main view", ->
        expect(@showAppsLibraryStub).toHaveBeenCalled()
        
      it "stops listening on the old apps library view", ->
        expect(@stopListeningStub).toHaveBeenCalledWith(@oldAppsLibraryView)
        
      it "listens for installAppClicked on the apps library view", ->
        expect(@listenToStub).toHaveBeenCalledWith(@appsLibraryView, "installAppClicked", TuringEmailApp.installAppClicked)
        
    describe "#showSettings", ->
      beforeEach ->
        @oldSettingsView = TuringEmailApp.settingsView = {}
        
        @settingsView = {}
        @showSettingsStub = sinon.stub(TuringEmailApp.views.mainView, "showSettings", => @settingsView)
        @listenToStub = sinon.stub(TuringEmailApp, "listenTo", ->)
        @stopListeningStub = sinon.stub(TuringEmailApp, "stopListening", ->)
        
        @server.restore()

        brainRulesFixtures = fixture.load("rules/brain_rules.fixture.json", true)
        @validBrainRulesFixture = brainRulesFixtures[0]

        emailRulesFixtures = fixture.load("rules/email_rules.fixture.json", true)
        @validEmailRulesFixture = emailRulesFixtures[0]

        @server = sinon.fakeServer.create()
        @server.respondWith "GET", "/api/v1/genie_rules", JSON.stringify(@validBrainRulesFixture)
        @server.respondWith "GET", "/api/v1/email_rules", JSON.stringify(@validEmailRulesFixture)

        userSettingsData = FactoryGirl.create("UserSettings")
        TuringEmailApp.models.userSettings = new TuringEmailApp.Models.UserSettings(userSettingsData)
        
        TuringEmailApp.showSettings()

      afterEach ->
        @server.restore()

        @stopListeningStub.restore()
        @listenToStub.restore()
        @showSettingsStub.restore()

      it "shows the Settings on the main view", ->
        expect(@showSettingsStub).toHaveBeenCalled()
        @showSettingsStub.restore()

      it "stops listening on the old settings view", ->
        expect(@stopListeningStub).toHaveBeenCalledWith(@oldSettingsView)

      it "listens for uninstallAppClicked on the settings view", ->
        expect(@listenToStub).toHaveBeenCalledWith(@settingsView, "uninstallAppClicked", TuringEmailApp.uninstallAppClicked)

      it "loads the brain rules", ->
        @server.respond()
        validateBrainRulesAttributes(TuringEmailApp.collections.brainRules.models[0].toJSON())

      it "loads the email rules", ->
        @server.respond()
        validateEmailRulesAttributes(TuringEmailApp.collections.emailRules.models[0].toJSON())

    describe "#showAnalytics", ->
      beforeEach ->
        @showAnalyticsSpy = sinon.spy(TuringEmailApp.views.mainView, "showAnalytics")

        TuringEmailApp.showAnalytics()

      afterEach ->
        @showAnalyticsSpy.restore()

      it "shows the Analytics on the main view", ->
        expect(@showAnalyticsSpy).toHaveBeenCalled()

    describe "#showReport", ->
      beforeEach ->
        @showReportSpy = sinon.spy(TuringEmailApp.views.mainView, "showReport")

        TuringEmailApp.showReport(TuringEmailApp.Models.Reports.AttachmentsReport,
                                  TuringEmailApp.Views.Reports.AttachmentsReportView)

      afterEach ->
        @showReportSpy.restore()

      it "shows the Analytics on the main view", ->
        expect(@showReportSpy).toHaveBeenCalled()
