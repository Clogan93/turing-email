describe "TuringEmailApp", ->
  beforeEach ->
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  it "has the app objects defined", ->
    expect(TuringEmailApp.Models).toBeDefined()
    expect(TuringEmailApp.Views).toBeDefined()
    expect(TuringEmailApp.Collections).toBeDefined()
    expect(TuringEmailApp.Routers).toBeDefined()
    
  describe "#start", ->
    it "defines the model, view, collection, and router containers", ->
      TuringEmailApp.start()
      
      expect(TuringEmailApp.models).toBeDefined()
      expect(TuringEmailApp.views).toBeDefined()
      expect(TuringEmailApp.collections).toBeDefined()
      expect(TuringEmailApp.routers).toBeDefined()

    setupFunctions = ["setupSearchBar", "setupComposeButton", "setupFiltering", "setupToolbar", "setupUser",
                      "setupEmailFolders", "loadEmailFolders", "setupComposeView", "setupEmailThreads", "setupRouters"]
    for setupFunction in setupFunctions  
      it "calls the " + setupFunction + " function", ->
        spy = sinon.spy(TuringEmailApp, setupFunction)
        TuringEmailApp.start()
        expect(spy).toHaveBeenCalled()
        spy.restore()
        
    it "starts the backbone history", ->
      TuringEmailApp.start()
      expect(Backbone.History.started).toBeTruthy()
      
  describe "#startEmailSync", ->
    beforeEach ->
      @spy = sinon.spy(window, "setInterval")
      TuringEmailApp.startEmailSync()
      
    afterEach ->
      @spy.restore()
    
    it "creates the sync email interval", ->
      expect(@spy).toHaveBeenCalledWith(TuringEmailApp.syncEmail, 60000)

  describe "setup functions", ->
    describe "#setupSearchBar", ->
      beforeEach ->
        @divSearchForm = $('<form role="search" id="top-search-form" class="navbar-form-custom"></form>').appendTo("body")
        
        TuringEmailApp.setupSearchBar()
       
      afterEach ->
        @divSearchForm.remove()
  
      it "hooks the submit action on the header search form", ->
        expect(@divSearchForm).toHandle("submit")
       
      it "prevents the default submit action", ->
        selector = "#" + @divSearchForm.attr("id")
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
        @divComposeButton = $('<button id="compose_button" type="button">Compose Email</button>').appendTo("body")
        
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

    describe "#setupFiltering", ->
      beforeEach ->
        @createFilterDiv = $('<div class="create_filter"><div />').appendTo("body")
        @filterFormDiv = $('<div id="filter_form"><div />').appendTo("body")
        @dropdownDiv = $('<div class="dropdown"><a href="#"></a></div>').appendTo("body")
        
        TuringEmailApp.setupFiltering()
      
      afterEach ->
        @createFilterDiv.remove()
        @filterFormDiv.remove()
        @dropdownDiv.remove()
  
      it "hooks the click action on the email filter dropdown", ->
        expect($(".create_filter")).toHandle("click")
  
      describe "when the create filter link is clicked", ->
        it "triggers the click.bs.dropdown event on the dropdown link", ->
          spy = spyOnEvent('.dropdown a', 'click.bs.dropdown')
          $('.create_filter').click()
          expect('click.bs.dropdown').toHaveBeenTriggeredOn('.dropdown a')
          expect(spy).toHaveBeenTriggered()
  
      it "hooks the submit action on the filter form", ->
        expect($("#filter_form")).toHandle("submit")
  
      describe "when the filter form is submitted", ->
        it "posts the email rule to the server", ->
          $("#filter_form").submit()
          
          expect(@server.requests.length).toEqual 1
          
          request = @server.requests[0]
          # TODO test posted form values
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/genie_rules"

        it "triggers the click.bs.dropdown event on the dropdown link", ->
          spy = spyOnEvent('.dropdown a', 'click.bs.dropdown')
          $("#filter_form").submit()
          expect('click.bs.dropdown').toHaveBeenTriggeredOn('.dropdown a')
          expect(spy).toHaveBeenTriggered()
        
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
                           "labelAsClicked", "moveToFolderClicked", "refreshClicked", "searchClicked"]
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
  
    describe "#setupUser", ->
      beforeEach ->
        @server.restore()
        
        userFixtures = fixture.load("user.fixture.json");
        @validUserFixture = userFixtures[0]["valid"]
  
        userSettingsFixtures = fixture.load("user_settings.fixture.json");
        @validUserSettingsFixture = userSettingsFixtures[0]["valid"]
        
        @server = sinon.fakeServer.create()
  
        @server.respondWith "GET", "/api/v1/users/current", JSON.stringify(@validUserFixture)
        @server.respondWith "GET", "/api/v1/user_configurations", JSON.stringify(@validUserSettingsFixture)
        
        TuringEmailApp.setupUser()
        
        @server.respond()
      
      it "loads the user and user settings", ->
        validateUserAttributes(TuringEmailApp.models.user.toJSON())
        validateUserSettingsAttributes(TuringEmailApp.models.userSettings.toJSON())
        
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
  
  describe "after start", ->
    beforeEach ->
      TuringEmailApp.start()
      @server.restore()
      @server = sinon.fakeServer.create()
      
    describe "getters", ->
      describe "#selectedEmailThread", ->
        beforeEach ->
          @server.restore()
          [@server, @emailThread] = window.specPrepareEmailThreadFetch()

          @emailThread.fetch()
          @server.respond()
    
          TuringEmailApp.views.emailThreadsListView.collection.add(@emailThread)
          TuringEmailApp.views.emailThreadsListView.select(@emailThread)
          
        it "returns the selected email thread", ->
          expect(TuringEmailApp.selectedEmailThread()).toEqual(@emailThread)
          
      describe "#selectedEmailFolder", ->
        beforeEach ->
          @server.restore()
          @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
          [@server] = specPrepareEmailFoldersFetch()

          @emailFolders.fetch()
          @server.respond()
          
          TuringEmailApp.views.emailFoldersTreeView.select(@emailFolders.models[0])

        it "returns the selected email folder", ->
          expect(TuringEmailApp.selectedEmailFolder()).toEqual(@emailFolders.models[0])

      describe "#selectedEmailFolderID", ->
        beforeEach ->
          @server.restore()
          @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
          [@server] = specPrepareEmailFoldersFetch(@emailFolders)

          @emailFolders.fetch()
          @server.respond()

          TuringEmailApp.views.emailFoldersTreeView.select(@emailFolders.models[0])

        it "returns the selected email folder id", ->
          expect(TuringEmailApp.selectedEmailFolderID()).toEqual(@emailFolders.models[0].get("label_id"))

    describe "setters", ->
      describe "#currentEmailThreadIs", ->
        beforeEach ->
          @loadEmailThreadSpy = sinon.spy(TuringEmailApp, "loadEmailThread")
          
          @showEmailThreadSpy = sinon.spy(TuringEmailApp, "showEmailThread")
          @selectSpy = sinon.spy(TuringEmailApp.views.emailThreadsListView, "select")
          @deselectSpy = sinon.spy(TuringEmailApp.views.emailThreadsListView, "deselect")
          @uncheckAllCheckboxSpy = sinon.spy(TuringEmailApp.views.toolbarView, "uncheckAllCheckbox")

          @changeSelectedEmailThreadSpy = sinon.backbone.spy(TuringEmailApp, "change:selectedEmailThread")

        afterEach ->
          @loadEmailThreadSpy.restore()
          
          @showEmailThreadSpy.restore()
          @selectSpy.restore()
          @deselectSpy.restore()
          @uncheckAllCheckboxSpy.restore()

          @changeSelectedEmailThreadSpy.restore()

        describe "the email thread exists", ->
          beforeEach ->
            @server.restore()
            [@server] = specPrepareEmailThreadsFetch(TuringEmailApp.collections.emailThreads)

            TuringEmailApp.collections.emailThreads.fetch()
            @server.respond()

            @emailThread = TuringEmailApp.collections.emailThreads.models[0]
          
          describe "the email thread is currently displayed", ->
            beforeEach ->
              TuringEmailApp.currentEmailThreadView = {model: TuringEmailApp.collections.emailThreads.models[0]}

              TuringEmailApp.currentEmailThreadIs(TuringEmailApp.collections.emailThreads.models[0].get("uid"))
              
            afterEach ->
              TuringEmailApp.currentEmailThreadView = null

            it "does NOT selects the thread", ->
              expect(@selectSpy).not.toHaveBeenCalled()

            it "does NOT shows the email thread", ->
              expect(@showEmailThreadSpy).not.toHaveBeenCalled()
    
            it "does NOT unchecks all the checkboes", ->
              expect(@uncheckAllCheckboxSpy).not.toHaveBeenCalled()
    
            it "does NOT trigger the change:selectedEmailThread event", ->
              expect(@changeSelectedEmailThreadSpy).not.toHaveBeenCalled()

          describe "the email thread is not currently displayed", ->
            beforeEach ->
              TuringEmailApp.currentEmailThreadIs(@emailThread.get("uid"))

            it "loads the email thread", ->
              expect(@loadEmailThreadSpy).toHaveBeenCalled()              
                
            it "selects the thread", ->
              expect(@selectSpy).toHaveBeenCalledWith(@emailThread)
  
            it "shows the email thread", ->
              expect(@showEmailThreadSpy).toHaveBeenCalled()
  
            it "unchecks all the checkboes", ->
              expect(@uncheckAllCheckboxSpy).toHaveBeenCalled()
  
            it "triggers the change:selectedEmailThread event", ->
              expect(@changeSelectedEmailThreadSpy).toHaveBeenCalledWith(TuringEmailApp, @emailThread)

        describe "clear the email thread", ->
          beforeEach ->
            TuringEmailApp.currentEmailThreadIs(".")
          
          it "shows the email thread", ->
            expect(@showEmailThreadSpy).toHaveBeenCalled()

          it "deselects the selected thread", ->
            expect(@deselectSpy).toHaveBeenCalled()

          it "unchecks all the checkboes", ->
            expect(@uncheckAllCheckboxSpy).toHaveBeenCalled()

          it "triggers the change:selectedEmailThread event", ->
            expect(@changeSelectedEmailThreadSpy).toHaveBeenCalledWith(TuringEmailApp, null)
          
      describe "#currentEmailFolderIs", ->
        beforeEach ->
          @server.restore()
          [@server, @validEmailThreadsFixture] = specPrepareEmailThreadsFetch(TuringEmailApp.collections.emailThreads)

          @reloadEmailThreadsSpy = sinon.spy(TuringEmailApp, "reloadEmailThreads")
          @moveTuringEmailReportToTopSpy = sinon.spy(TuringEmailApp, "moveTuringEmailReportToTop")
          @emailFoldersTreeViewSelectSpy = sinon.spy(TuringEmailApp.views.emailFoldersTreeView, "select")

          @changecurrentEmailFolderSpy = sinon.backbone.spy(TuringEmailApp, "change:currentEmailFolder")
          
          TuringEmailApp.currentEmailFolderIs("INBOX")
          
        afterEach ->
          @reloadEmailThreadsSpy.restore()
          @moveTuringEmailReportToTopSpy.restore()
          @emailFoldersTreeViewSelectSpy.restore()

          @changecurrentEmailFolderSpy.restore()
          
        describe "after fetch", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.fetch()
            @server.respond()
  
            @emailFolder = TuringEmailApp.collections.emailFolders.getEmailFolder("INBOX")
          
          it "reloads the email threads", ->
            expect(@reloadEmailThreadsSpy).toHaveBeenCalled()
            
          it "moves the Turing email report to the top", ->
            expect(@moveTuringEmailReportToTopSpy).toHaveBeenCalled()
            
          it "selects the email folder on the tree view", ->
            expect(@emailFoldersTreeViewSelectSpy).toHaveBeenCalledWith(@emailFolder, silent: true)
  
          it "triggers the change:currentEmailFolder event", ->
            expect(@changecurrentEmailFolderSpy).toHaveBeenCalledWith(TuringEmailApp, @emailFolder)

        describe "before fetch", ->
          beforeEach ->
            @currentEmailThreadIsSpy = sinon.spy(TuringEmailApp, "currentEmailThreadIs")

          afterEach ->
            @currentEmailThreadIsSpy.restore()
            
          describe "no draft", ->  
            beforeEach ->
              @validEmailThreadsFixture[0]["emails"][0]["draft_id"] = null
              @server.respondWith "GET", TuringEmailApp.collections.emailThreads.url, JSON.stringify(@validEmailThreadsFixture)

            describe "with split pane", ->
              beforeEach ->
                @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
                TuringEmailApp.isSplitPaneMode = -> return true

                TuringEmailApp.collections.emailThreads.fetch()
                @server.respond()
                @emailThread = TuringEmailApp.collections.emailThreads.models[0]

              afterEach ->
                TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction

              it "selects an email thread", ->
                expect(@currentEmailThreadIsSpy).toHaveBeenCalledWith(@emailThread.get("uid"))

            describe "with NO split pane", ->
              beforeEach ->
                @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
                TuringEmailApp.isSplitPaneMode = -> return false

                TuringEmailApp.collections.emailThreads.fetch()
                @server.respond()
                @emailThread = TuringEmailApp.collections.emailThreads.models[0]

              afterEach ->
                TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction

              it "does NOT selects an email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalledWith(@emailThread.get("uid"))

          describe "with draft", ->
            beforeEach ->
              @validEmailThreadsFixture[0]["emails"][0]["draft_id"] = "1"
              @server.respondWith "GET", TuringEmailApp.collections.emailThreads.url, JSON.stringify(@validEmailThreadsFixture)
              
            describe "with split pane", ->
              beforeEach ->
                @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
                TuringEmailApp.isSplitPaneMode = -> return true

                TuringEmailApp.collections.emailThreads.fetch()
                @server.respond()
                @emailThread = TuringEmailApp.collections.emailThreads.models[0]

              afterEach ->
                TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction

              it "does NOT selects an email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalledWith(@emailThread.get("uid"))

            describe "with NO split pane", ->
              beforeEach ->
                @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
                TuringEmailApp.isSplitPaneMode = -> return false

                TuringEmailApp.collections.emailThreads.fetch()
                @server.respond()
                @emailThread = TuringEmailApp.collections.emailThreads.models[0]

              afterEach ->
                TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction

              it "does NOT selects an email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalledWith(@emailThread.get("uid"))

    describe "#syncEmail", ->
      beforeEach ->
        TuringEmailApp.syncEmail()

        @reloadEmailThreadsSpy = sinon.spy(TuringEmailApp, "reloadEmailThreads")
        
      afterEach ->
        @reloadEmailThreadsSpy.restore()
        
      it "posts the sync email request", ->
        expect(@server.requests.length).toEqual 1

        request = @server.requests[0]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "api/v1/email_accounts/sync"

      it "does NOT reload the emails threads when emails have NOT been synced", ->
        @server.respondWith "POST", "api/v1/email_accounts/sync",
                            [200, {"Content-Type": "application/json"}, JSON.stringify(synced_emails: false)]
        @server.respond()

        expect(@reloadEmailThreadsSpy).not.toHaveBeenCalled()
        
      it "reloads the emails threads when emails have been synced", ->
        @server.respondWith "POST", "api/v1/email_accounts/sync",
                            [200, {"Content-Type": "application/json"}, JSON.stringify(synced_emails: true)]
        @server.respond()

        expect(@reloadEmailThreadsSpy).toHaveBeenCalled()

    describe "Alert Functions", ->
      describe "#showAlert", ->
        beforeEach ->
          @alertText = "test"
          @alertClass = "testAlert"
          @alertSelector = "." + @alertClass

          @removeAlertSpy = sinon.spy(TuringEmailApp, "removeAlert")
          
        afterEach ->
          TuringEmailApp.removeAlert(@token)
          @removeAlertSpy.restore()
          
        describe "when there is no current alert", ->
          beforeEach ->
            expect(TuringEmailApp.currentAlert).not.toBeDefined()
            @token = TuringEmailApp.showAlert(@alertText, @alertClass)
            
          it "shows the alert", ->
            expect($(@alertSelector).length).toEqual(1)
            expect($(@alertSelector).text()).toEqual(@alertText)
            
          it "does not remove an existing alert", ->
            expect(@removeAlertSpy).not.toHaveBeenCalled()
            
          it "returns the token", ->
            expect($(@alertSelector).data("token")).toEqual(@token)
      
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
          @fetchSpy = sinon.spy(TuringEmailApp.collections.emailFolders, "fetch")
          @resetSpy = sinon.backbone.spy(TuringEmailApp.collections.emailFolders, "reset")
          @changeEmailFoldersSpy = sinon.backbone.spy(TuringEmailApp, "change:emailFolders")
          
        afterEach ->
          @fetchSpy.restore()
          @resetSpy.restore()
          @changeEmailFoldersSpy.restore()
          
        it "fetches the email folders", ->
          TuringEmailApp.loadEmailFolders()
          expect(@fetchSpy).toHaveBeenCalled()
          
        describe "after the email folders are fetched", ->
          beforeEach ->
            @server.restore()
            [@server] = specPrepareEmailFoldersFetch()
            
            TuringEmailApp.loadEmailFolders()
            @server.respond()

          it "the collection resets", ->
            expect(@resetSpy).toHaveBeenCalled()

          it "triggers the change:emailFolders event", ->
            expect(@changeEmailFoldersSpy).toHaveBeenCalled()
  
    describe "Email Thread Functions", ->
      describe "#loadEmailThread", ->
        beforeEach ->
          @callback = sinon.spy()
          #TuringEmailApp.loadEmailThread()
          
        afterEach ->
          @callback.restore()
          
        describe "when the email thread is in the collection", ->
          #it "calls the callback", ->
      
      describe "#reloadEmailThreads", ->
        return
      
      describe "#applyActionToSelectedThreads", ->
        return

  describe "#emailFolderSelected", ->

    describe "when the email folder is defined", ->
      beforeEach ->
        @emailFolder = new TuringEmailApp.Models.EmailFolder()

      describe "when the window location is already set to show the email folder page", ->
        beforeEach ->
          @emailFolder.set("label_id", "INBOX")

        it "navigates to the email folder url", ->
          spy = sinon.spy(TuringEmailApp.routers.emailFoldersRouter, "showFolder")
          TuringEmailApp.emailFolderSelected null, @emailFolder
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(@emailFolder.get("label_id"))
          spy.restore()

      describe "when the window location is not already set to show the email folder page", ->
        beforeEach ->
          @emailFolder.set("label_id", "Label_45")

        it "navigates to the email folder url", ->
          spy = sinon.spy(TuringEmailApp.routers.emailFoldersRouter, "navigate")
          TuringEmailApp.emailFolderSelected null, @emailFolder
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith("#email_folder/" + @emailFolder.get("label_id"))
          spy.restore()

  describe "#draftChanged", ->

    describe "when the selected email folder is DRAFT", ->
      beforeEach ->
        @selectedEmailFolderIDFunction = TuringEmailApp.selectedEmailFolderID
        TuringEmailApp.selectedEmailFolderID = -> return "DRAFT"

      afterEach ->
        TuringEmailApp.selectedEmailFolderID = @selectedEmailFolderIDFunction

      it "reloads the email thread if the selected email folder is DRAFT", ->
        spy = sinon.spy(TuringEmailApp, "reloadEmailThreads")
        TuringEmailApp.draftChanged()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "when the selected email folder is not DRAFT", ->
      beforeEach ->
        @selectedEmailFolderIDFunction = TuringEmailApp.selectedEmailFolderID
        TuringEmailApp.selectedEmailFolderID = -> return "INBOX"

      afterEach ->
        TuringEmailApp.selectedEmailFolderID = @selectedEmailFolderIDFunction

      it "does not reloads the email thread if the selected email folder is DRAFT", ->
        spy = sinon.spy(TuringEmailApp, "reloadEmailThreads")
        TuringEmailApp.draftChanged()
        expect(spy).not.toHaveBeenCalled()
        spy.restore()

  describe "#emailThreadSeenChanged", ->
    beforeEach ->
      @server.restore()
      [@server] = specPrepareEmailThreadsFetch(TuringEmailApp.collections.emailThreads)
      [@server] = specPrepareEmailFoldersFetch(TuringEmailApp.collections.emailFolders)
      TuringEmailApp.collections.emailThreads.fetch(reset: true)
      TuringEmailApp.collections.emailFolders.fetch(reset: true)
      @server.respond()
      @selectedEmailFolderIDFunction = TuringEmailApp.selectedEmailFolderID
      TuringEmailApp.selectedEmailFolderID = -> return "INBOX"

    afterEach ->
      TuringEmailApp.selectedEmailFolderID = @selectedEmailFolderIDFunction

    it "triggers a change:emailFolderUnreadCount event", ->
      spy = sinon.backbone.spy(TuringEmailApp, "change:emailFolderUnreadCount")

      emailThread = TuringEmailApp.collections.emailThreads.models[0]
      TuringEmailApp.emailThreadSeenChanged emailThread, true

      expect(spy).toHaveBeenCalled()

  describe "#isSplitPaneMode", ->
    beforeEach ->
      userSettingsFixtures = fixture.load("user_settings.fixture.json");
      @validUserSettingsFixture = userSettingsFixtures[0]["valid"]

      @server = sinon.fakeServer.create()

      @server.respondWith "GET", "/api/v1/user_configurations", JSON.stringify(@validUserSettingsFixture)

      TuringEmailApp.models.userSettings = new TuringEmailApp.Models.UserSettings()
      TuringEmailApp.models.userSettings.fetch()

      @server.respond()

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

      it "should return false", ->
        expect(TuringEmailApp.isSplitPaneMode()).toBeFalsy()

  describe "#showEmailThread", ->
    beforeEach ->
      @server.restore()
      [@server] = specPrepareEmailThreadsFetch(TuringEmailApp.collections.emailThreads)
      TuringEmailApp.collections.emailThreads.fetch(reset: true)
      @server.respond()

    it "marks the email thread as read", ->
      spy = sinon.spy(TuringEmailApp.views.emailThreadsListView, "markEmailThreadRead")
      emailThread = TuringEmailApp.collections.emailThreads.models[0]
      TuringEmailApp.showEmailThread emailThread
      expect(spy).toHaveBeenCalled()
      expect(spy).toHaveBeenCalledWith(emailThread)

    emailThreadViewEvents = ["goBackClicked", "replyClicked", "forwardClicked", "archiveClicked", "trashClicked"]
    for event in emailThreadViewEvents
      it "hooks the emailThreadView " + event + " event", ->
        spy = sinon.spy(TuringEmailApp, event)
        
        emailThread = TuringEmailApp.collections.emailThreads.models[0]
        TuringEmailApp.showEmailThread emailThread
        TuringEmailApp.currentEmailThreadView.trigger(event)
        
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "when split pane mode is on", ->
      beforeEach ->
        @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
        TuringEmailApp.isSplitPaneMode = -> return true
        @previewPanelDiv = $("<div />", {id: "preview_panel"}).appendTo("body")
        @previewContentDiv = $("<div />", {id: "preview_content"}).appendTo("body")

      afterEach ->
        TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction
        @previewPanelDiv.remove()
        @previewContentDiv.remove()
  
      it "shows the preview panel element", ->
        emailThread = TuringEmailApp.collections.emailThreads.models[0]
        TuringEmailApp.showEmailThread(emailThread)
        expect($('#preview_panel').is(':visible')).toBeTruthy()

      it "renders the email thread in the preview panel", ->
        emailThread = TuringEmailApp.collections.emailThreads.models[0]
        TuringEmailApp.showEmailThread(emailThread)
        expect(TuringEmailApp.currentEmailThreadView.$el).toEqual $('#preview_content')

    describe "when split pane mode is off", ->
      beforeEach ->
        @isSplitPaneModeFunction = TuringEmailApp.isSplitPaneMode
        TuringEmailApp.isSplitPaneMode = -> return false
        @emailFolderMailHeader = $("<div />", {id: "email-folder-mail-header"}).appendTo("body")
        @emailTableBodyDiv = $("<div />", {id: "email_table_body"}).appendTo("body")

      afterEach ->
        TuringEmailApp.isSplitPaneMode = @isSplitPaneModeFunction
        @emailFolderMailHeader.remove()
        @emailTableBodyDiv.remove()

      it "hides the email folder mail header", ->
        emailThread = TuringEmailApp.collections.emailThreads.models[0]
        TuringEmailApp.showEmailThread(emailThread)
        expect($('#email-folder-mail-header').is(':hidden')).toBeTruthy()

      it "renders the email thread in the email table body", ->
        emailThread = TuringEmailApp.collections.emailThreads.models[0]
        TuringEmailApp.showEmailThread(emailThread)
        expect(TuringEmailApp.currentEmailThreadView.$el).toEqual $('#email_table_body')

    describe "when the current email Thread is not null", ->
      beforeEach ->
        emailThread = TuringEmailApp.collections.emailThreads.models[0]
        TuringEmailApp.showEmailThread(emailThread)

      it "stops listening to the current email thread view", ->
        appSpy = sinon.spy(TuringEmailApp, "stopListening")
        viewSpy = sinon.spy(TuringEmailApp.currentEmailThreadView, "stopListening")
        emailThread = TuringEmailApp.collections.emailThreads.models[1]
        TuringEmailApp.showEmailThread emailThread
        expect(appSpy).toHaveBeenCalled()
        expect(viewSpy).toHaveBeenCalled()

  describe "#showEmailEditorWithEmailThread", ->
    beforeEach ->
      @server.restore()
      [@server] = specPrepareEmailThreadsFetch(TuringEmailApp.collections.emailThreads)
      TuringEmailApp.collections.emailThreads.fetch(reset: true)
      @server.respond()

    it "loads the email thread", ->
      spy = sinon.spy(TuringEmailApp, "loadEmailThread")
      emailThread = TuringEmailApp.collections.emailThreads.models[0]
      TuringEmailApp.showEmailEditorWithEmailThread emailThread.get("uid")
      expect(spy).toHaveBeenCalled()
      expect(spy).toHaveBeenCalledWith(emailThread.get("uid"))

    it "shows the compose view", ->
      spy = sinon.spy(TuringEmailApp.views.composeView, "show")
      emailThread = TuringEmailApp.collections.emailThreads.models[0]
      TuringEmailApp.showEmailEditorWithEmailThread emailThread.get("uid")
      expect(spy).toHaveBeenCalled()

    describe "when in draft mode", ->

      it "loads the email draft", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailDraft")
        emailThread = TuringEmailApp.collections.emailThreads.models[0]
        TuringEmailApp.showEmailEditorWithEmailThread emailThread.get("uid")
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailThread.get("emails")[0])

    describe "when in forward mode", ->

      it "loads the email as a forward", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailAsForward")
        emailThread = TuringEmailApp.collections.emailThreads.models[0]
        TuringEmailApp.showEmailEditorWithEmailThread emailThread.get("uid"), "forward"
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailThread.get("emails")[0])

    describe "when in reply mode", ->

      it "loads the email as a reply", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailAsReply")
        emailThread = TuringEmailApp.collections.emailThreads.models[0]
        TuringEmailApp.showEmailEditorWithEmailThread emailThread.get("uid"), "reply"
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailThread.get("emails")[0])

  describe "#moveTuringEmailReportToTop", ->
    beforeEach ->
      @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()

      @listViewDiv = $("<div />", {id: "email_table_body"}).appendTo("body")
      TuringEmailApp.views.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView(
        el: @listViewDiv
        collection: @emailThreads
      )

      @server.restore()
      [@server] = specPrepareEmailThreadsFetch(@emailThreads)
      @emailThreads.fetch(reset: true)
      @server.respond()

    afterEach ->
      @server.restore()
      @listViewDiv.remove()

    describe "if there is not a report email", ->
      it "should leave the emails in the same order", ->
        emailThreadsBefore = TuringEmailApp.views.emailThreadsListView.collection.clone()
        emailTableBodyBefore = TuringEmailApp.views.emailThreadsListView.$el
        
        TuringEmailApp.moveTuringEmailReportToTop TuringEmailApp.views.emailThreadsListView
        
        emailTableBodyAfter = TuringEmailApp.views.emailThreadsListView.$el
        emailThreadsAfter = TuringEmailApp.views.emailThreadsListView.collection
  
        expect(emailThreadsAfter.length).toEqual emailThreadsBefore.length
        expect(emailThreadsAfter.models).toEqual emailThreadsBefore.models
        expect(emailTableBodyBefore).toEqual emailTableBodyAfter

    describe "if there is a report email", ->
      beforeEach ->
        turingEmailThread = _.values(TuringEmailApp.views.emailThreadsListView.listItemViews)[0].model
  
        TuringEmailApp.views.emailThreadsListView.collection.remove turingEmailThread
        turingEmailThread.get("emails")[0].subject = "Turing Email - Your daily Genie Report!"
        TuringEmailApp.views.emailThreadsListView.collection.add turingEmailThread

      it "should move the email to the top", ->
        expect(TuringEmailApp.views.emailThreadsListView.$el.children()[0]).not.toContainText("Turing Email")
  
        TuringEmailApp.moveTuringEmailReportToTop TuringEmailApp.views.emailThreadsListView
  
        expect(TuringEmailApp.views.emailThreadsListView.$el.children()[0]).toContainText("Turing Email")

  describe "showEmails", ->

    it "calls hide all", ->
      spy = sinon.spy(TuringEmailApp, "hideAll")
      TuringEmailApp.showEmails()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe "hideEmails", ->
    beforeEach ->
      @emailTableDiv = $("<div />", {id: "email_table"}).appendTo("body")
      @pagesDiv = $("<div />", {id: "pages"}).appendTo("body")
      @previewPanelDiv = $("<div />", {id: "preview_panel"}).appendTo("body")
      @mailBoxHeader = $("<div class='mail-box-header'></div>").appendTo("body")
      @tableTableMail = $("<table class='table-mail'></table>").appendTo("body")

    afterEach ->
      @emailTableDiv.remove()
      @pagesDiv.remove()
      @previewPanelDiv.remove()
      @mailBoxHeader.remove()
      @tableTableMail.remove()

    it "hides the preview panel element", ->
      TuringEmailApp.hideEmails()
      expect($('#preview_panel').is(':hidden')).toBeTruthy()

    it "hides the mail box header element", ->
      TuringEmailApp.hideEmails()
      expect($('.mail-box-header').is(':hidden')).toBeTruthy()

    it "hides the mail table element", ->
      TuringEmailApp.hideEmails()
      expect($('table.table-mail').is(':hidden')).toBeTruthy()

    it "hides the pages", ->
      TuringEmailApp.hideEmails()
      expect($('#pages').is(':hidden')).toBeTruthy()

    it "hides the email table element", ->
      TuringEmailApp.hideEmails()
      expect($('#email_table').is(':hidden')).toBeTruthy()

  describe "showSettings", ->

    it "calls hide all", ->
      spy = sinon.spy(TuringEmailApp, "hideAll")
      TuringEmailApp.showSettings()
      expect(spy).toHaveBeenCalled()
      spy.restore()

    it "sets the main email list content height to be 100%", ->
      $("<div class='main_email_list_content'></div>").appendTo("body")
      TuringEmailApp.showReports()
      expect($(".main_email_list_content")[0].style.height).toEqual "100%"

  describe "hideSettings", ->
    beforeEach ->
      @settingsDiv = $("<div />", {id: "settings"}).appendTo("body")

    afterEach ->
      @settingsDiv.remove()

    it "hides the settings element", ->
      expect($('#settings').is(':hidden')).toBeFalsy()
      TuringEmailApp.hideSettings()
      expect($('#settings').is(':hidden')).toBeTruthy()

  describe "showReports", ->
    beforeEach ->
      @settingsDiv = $("<div />", {id: "settings"}).appendTo("body")
      @reportsDiv = $("<div />", {id: "reports"}).appendTo("body")

    afterEach ->
      @settingsDiv.remove()
      @reportsDiv.remove()

    it "calls hide all", ->
      spy = sinon.spy(TuringEmailApp, "hideAll")
      TuringEmailApp.showReports()
      expect(spy).toHaveBeenCalled()
      spy.restore()

    it "hides the settings element", ->
      TuringEmailApp.showReports()
      expect($('#settings').is(':hidden')).toBeTruthy()

    it "shows the reports element", ->
      TuringEmailApp.showReports()
      expect($('#reports').is(':hidden')).toBeFalsy()

    it "sets the main email list content height to be 100%", ->
      $("<div class='main_email_list_content'></div>").appendTo("body")
      TuringEmailApp.showReports()
      expect($(".main_email_list_content")[0].style.height).toEqual "100%"

  describe "hideReports", ->
    beforeEach ->
      @reportsDiv = $("<div />", {id: "reports"}).appendTo("body")

    afterEach ->
      @reportsDiv.remove()

    it "hides the reports element", ->
      expect($('#reports').is(':hidden')).toBeFalsy()
      TuringEmailApp.hideReports()
      expect($('#reports').is(':hidden')).toBeTruthy()

  describe "hideAll", ->

    it "hides the emails", ->
      spy = sinon.spy(TuringEmailApp, "hideEmails")
      TuringEmailApp.hideAll()
      expect(spy).toHaveBeenCalled()
      spy.restore()

    it "hides the reports", ->
      spy = sinon.spy(TuringEmailApp, "hideReports")
      TuringEmailApp.hideAll()
      expect(spy).toHaveBeenCalled()
      spy.restore()

    it "hides the settings", ->
      spy = sinon.spy(TuringEmailApp, "hideSettings")
      TuringEmailApp.hideAll()
      expect(spy).toHaveBeenCalled()
      spy.restore()
