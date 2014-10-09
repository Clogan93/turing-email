describe "TuringEmailApp", ->
  beforeEach ->
    @server = sinon.fakeServer.create()
    @mainDiv = $("<div />", id: "main").appendTo($("body"))

  afterEach ->
    @server.restore()
    @mainDiv.remove()

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

    setupFunctions = ["setupMainView", "setupSearchBar", "setupComposeButton", "setupFiltering", "setupToolbar", "setupUser",
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
    describe "#setupMainView", ->
      beforeEach ->
        TuringEmailApp.setupMainView()
        
      it "creates the main view", ->
        expect(TuringEmailApp.views.mainView).toBeDefined()

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

        [@server] = specPrepareUserSettingsFetch()
        @server.respondWith "GET", "/api/v1/users/current", JSON.stringify(@validUserFixture)
        
        TuringEmailApp.models.userSettings.fetch()
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
      TuringEmailApp.showEmails()
      
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
            expect(@changeEmailFoldersSpy).toHaveBeenCalledWith(TuringEmailApp, TuringEmailApp.collections.emailFolders)
  
    describe "Email Thread Functions", ->
      describe "#loadEmailThread", ->
        beforeEach ->
          @callback = sinon.spy()
          
          @server.restore()
          [@server] = specPrepareEmailThreadsFetch(TuringEmailApp.collections.emailThreads)

        describe "when the email thread is NOT in the collection", ->
          beforeEach ->
            @server.restore()
            [@server, @emailThread] = specPrepareEmailThreadFetch()
            
            @emailThread.fetch()
            @server.respond()
            
            TuringEmailApp.loadEmailThread(@emailThread.get("uid"), @callback)

          it "fetches the email thread and then calls the callback", ->
            expect(@callback).not.toHaveBeenCalled()
            @server.respond()
            expect(@callback).toHaveBeenCalled()
          
        describe "when the email thread is in the collection", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.fetch()
            @server.respond()
            TuringEmailApp.loadEmailThread(TuringEmailApp.collections.emailThreads.models[0].get("uid"), @callback)
            
          it "calls the callback", ->
            expect(@callback).toHaveBeenCalled()
      
      describe "#reloadEmailThreads", ->
        beforeEach ->
          @fetchSpy = sinon.spy(TuringEmailApp.collections.emailThreads, "fetch")
          @searchSpy = sinon.spy(TuringEmailApp.collections.emailThreads, "search")
          
          @success = sinon.spy()
          @error = sinon.spy()

        afterEach ->
          @searchSpy.restore()
          @fetchSpy.restore()

        describe "without query", ->
          it "fetches the email threads", ->
            TuringEmailApp.reloadEmailThreads(success: @success, error: @error)
            expect(@fetchSpy).toHaveBeenCalled()
            expect(@searchSpy).not.toHaveBeenCalled()
        
        describe "with query", ->
          it "searches for the email threads", ->
            TuringEmailApp.reloadEmailThreads(query: "test", success: @success, error: @error)
            expect(@fetchSpy).toHaveBeenCalled()
            expect(@searchSpy).toHaveBeenCalled()

        describe "on success", ->
          beforeEach ->
            [@server] = specPrepareEmailThreadsFetch(TuringEmailApp.collections.emailThreads)
            TuringEmailApp.collections.emailThreads.fetch()
            @server.respond()
            @oldEmailThreads = TuringEmailApp.collections.emailThreads.models

            @stopListeningSpy = sinon.spy(TuringEmailApp, "stopListening")
            @listenToSpy = sinon.spy(TuringEmailApp, "listenTo")

            TuringEmailApp.reloadEmailThreads(success: @success, error: @error)
            @server.respond()

          afterEach ->
            @stopListeningSpy.restore()
            @listenToSpy.restore()

          it "stops listening on the old models", ->
            expect(@stopListeningSpy).toHaveBeenCalledWith(oldEmailThread) for oldEmailThread in @oldEmailThreads

          it "listens for change:seen on the new models", ->
            for emailThread in TuringEmailApp.collections.emailThreads.models
              expect(@listenToSpy).toHaveBeenCalledWith(emailThread, "change:seen", TuringEmailApp.emailThreadSeenChanged)

          it "calls the success callback", ->
            expect(@success).toHaveBeenCalled()

          it "does NOT call the error callback", ->
            expect(@error).not.toHaveBeenCalled()

        describe "on error", ->
          beforeEach ->
            TuringEmailApp.reloadEmailThreads(success: @success, error: @error)
            @server.respond()

          it "does NOT call the success callback", ->
            expect(@success).not.toHaveBeenCalled()

          it "calls the error callback", ->
            expect(@error).toHaveBeenCalled()

      describe "#loadSearchResults", ->
        beforeEach ->
          @reloadEmailThreadsSpy = sinon.spy(TuringEmailApp, "reloadEmailThreads")
          @showEmailsStub = sinon.stub(TuringEmailApp, "showEmails", ->)
          
          @server.restore()
          [@server, @validEmailThreadSearchResultsFixture] = specPrepareSearchResultsFetch()

          TuringEmailApp.loadSearchResults("test")
          @server.respond()
          
        afterEach ->
          @showEmailsStub.restore()
          @reloadEmailThreadsSpy.restore()

        it "reloads the email threads", ->
          expect(@reloadEmailThreadsSpy).toHaveBeenCalled()
          
        describe "on success", ->
          it "shows the emails", ->
            expect(@showEmailsStub).toHaveBeenCalled()
            
      describe "#applyActionToSelectedThreads", ->
        beforeEach ->
          @singleAction = sinon.spy()
          @multiAction = sinon.spy()
      
          @server.restore()
          [@listViewDiv, @listView, @emailThreads, @server] = specCreateEmailThreadsListView()
      
          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads
      
        afterEach ->
          @listViewDiv.remove()
      
        describe "clearSelection", ->
          beforeEach ->
            @origisSplitPaneMode = TuringEmailApp.isSplitPaneMode
      
            @currentEmailThreadIsSpy = sinon.spy(TuringEmailApp, "currentEmailThreadIs")
            @goBackClickedSpy = sinon.spy(TuringEmailApp, "goBackClicked")
      
          afterEach ->
            @goBackClickedSpy.restore()
            @currentEmailThreadIsSpy.restore()
      
            TuringEmailApp.isSplitPaneMode = @origisSplitPaneMode
      
          describe "is true", ->
            describe "with split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return true
                TuringEmailApp.applyActionToSelectedThreads(@singleAction, @multiAction, true, true)
      
              it "clears the current email thread", ->
                expect(@currentEmailThreadIsSpy).toHaveBeenCalledWith(null)
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
          @server.restore()
          [@listViewDiv, @listView, @emailThreads, @server] = specCreateEmailThreadsListView()
  
          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads
          
        afterEach ->
          @listViewDiv.remove()
          
        describe "when an email thread is selected", ->
          beforeEach ->
            @markEmailThreadReadSpy = sinon.spy(@listView, "markEmailThreadRead")
            
            @emailThread = @emailThreads.models[0]
            @emailThread.seenIs(false)
            @listView.select(@emailThread)
            
            TuringEmailApp.readClicked()
          
          afterEach ->
            @markEmailThreadReadSpy.restore()
            
          it "sets the email thread to read", ->
            expect(email.seen).toBeTruthy() for email in @emailThread.get("emails")

          it "marks the email thread as read in the list view", ->
            expect(@markEmailThreadReadSpy).toHaveBeenCalledWith(@emailThread)
            
        describe "when an email thread is checked", ->
          beforeEach ->
            @markCheckedReadSpy = sinon.spy(@listView, "markCheckedRead")

            @emailThread = @emailThreads.models[0]
            @emailThread.seenIs(false)
            @listView.check(@emailThread)

            TuringEmailApp.readClicked()

          afterEach ->
            @markCheckedReadSpy.restore()

          it "sets the email thread to read", ->
            expect(email.seen).toBeTruthy() for email in @emailThread.get("emails")

          it "marks all the checked items in the list view as read", ->
            expect(@markCheckedReadSpy).toHaveBeenCalled()

      describe "#unreadClicked", ->
        beforeEach ->
          @server.restore()
          [@listViewDiv, @listView, @emailThreads, @server] = specCreateEmailThreadsListView()

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @markEmailThreadUnreadSpy = sinon.spy(@listView, "markEmailThreadUnread")

            @emailThread.seenIs(true)
            @listView.select(@emailThread)

            TuringEmailApp.unreadClicked()

          afterEach ->
            @markEmailThreadUnreadSpy.restore()

          it "sets the email thread to unread", ->
            expect(email.seen).toBeFalsy() for email in @emailThread.get("emails")

          it "marks the email thread as unread in the list view", ->
            expect(@markEmailThreadUnreadSpy).toHaveBeenCalledWith(@emailThread)

        describe "when an email thread is checked", ->
          beforeEach ->
            @markCheckedUnreadSpy = sinon.spy(@listView, "markCheckedUnread")

            @emailThread.seenIs(false)
            @listView.check(@emailThread)

            TuringEmailApp.unreadClicked()

          afterEach ->
            @markCheckedUnreadSpy.restore()

          it "sets the email thread to unread", ->
            expect(email.seen).toBeFalsy() for email in @emailThread.get("emails")

          it "marks all the checked items in the list view as unread", ->
            expect(@markCheckedUnreadSpy).toHaveBeenCalled()
            
      describe "#leftArrowClicked", ->
        beforeEach ->
          @origSelectedEmailFolderID = TuringEmailApp.selectedEmailFolderID
          @folderID = "test"
          TuringEmailApp.selectedEmailFolderID = => @folderID

          @navigateSpy = sinon.spy(TuringEmailApp.routers.emailFoldersRouter, "navigate")
          
        afterEach ->
          @navigateSpy.restore()
          TuringEmailApp.selectedEmailFolderID = @origSelectedEmailFolderID

        describe "page=1", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.page = 1
            TuringEmailApp.leftArrowClicked()
            
          it "does not go to the previous page", ->
            expect(@navigateSpy).not.toHaveBeenCalled()

        describe "page=2", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.page = 2
            TuringEmailApp.leftArrowClicked()

          it "goes to the previous page", ->
            expect(@navigateSpy).toHaveBeenCalledWith("#email_folder/" + @folderID + "/" + 1, trigger: true)

      describe "#rightArrowClicked", ->
        beforeEach ->
          @origSelectedEmailFolderID = TuringEmailApp.selectedEmailFolderID
          @folderID = "test"
          TuringEmailApp.selectedEmailFolderID = => @folderID

          TuringEmailApp.collections.emailThreads.page = 1

          @navigateSpy = sinon.spy(TuringEmailApp.routers.emailFoldersRouter, "navigate")

        afterEach ->
          @navigateSpy.restore()
          TuringEmailApp.selectedEmailFolderID = @origSelectedEmailFolderID

        describe "max threads per page are loaded", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.length = TuringEmailApp.Models.UserSettings.EmailThreadsPerPage
            TuringEmailApp.rightArrowClicked()

          it "goes to the next page", ->
            expect(@navigateSpy).toHaveBeenCalledWith("#email_folder/" + @folderID + "/" + 2, trigger: true)

        describe "max threads per page are not loaded", ->
          beforeEach ->
            TuringEmailApp.collections.emailThreads.length = TuringEmailApp.Models.UserSettings.EmailThreadsPerPage - 1
            TuringEmailApp.rightArrowClicked()

          it "does NOT go to the next page", ->
            expect(@navigateSpy).not.toHaveBeenCalled()

      describe "#labelAsClicked", ->
        beforeEach ->
          @server.restore()
          [@listViewDiv, @listView, @emailThreads, @server] = specCreateEmailThreadsListView()

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @applyGmailLabelSpy = sinon.spy(@emailThread, "applyGmailLabel")

            @listView.select(@emailThread)

            @labelID = "test"
            TuringEmailApp.labelAsClicked(@labelID)

          afterEach ->
            @applyGmailLabelSpy.restore()

          it "applies the label to the selected email thread", ->
            expect(@applyGmailLabelSpy).toHaveBeenCalledWith(@labelID)

        describe "when an email thread is checked", ->
          beforeEach ->
            @applyGmailLabelSpy = sinon.spy(TuringEmailApp.Models.EmailThread, "applyGmailLabel")

            @listView.check(@emailThread)

            @labelID = "test"
            TuringEmailApp.labelAsClicked(@labelID)

          afterEach ->
            @applyGmailLabelSpy.restore()

          it "applies the label to the checked email threads", ->
            expect(@applyGmailLabelSpy).toHaveBeenCalledWith([@emailThread.get("uid")], @labelID)

      describe "#moveToFolderClicked", ->
        beforeEach ->
          @server.restore()
          [@listViewDiv, @listView, @emailThreads, @server] = specCreateEmailThreadsListView()

          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = @emailThreads.models[0]

        afterEach ->
          @listViewDiv.remove()

        describe "when an email thread is selected", ->
          beforeEach ->
            @moveToFolderSpy = sinon.spy(@emailThread, "moveToFolder")

            @listView.select(@emailThread)

            @folderID = "test"
            TuringEmailApp.moveToFolderClicked(@folderID)

          afterEach ->
            @moveToFolderSpy.restore()

          it "moves the selected email thread to the folder", ->
            expect(@moveToFolderSpy).toHaveBeenCalledWith(@folderID)

        describe "when an email thread is checked", ->
          beforeEach ->
            @moveToFolderSpy = sinon.spy(TuringEmailApp.Models.EmailThread, "moveToFolder")

            @listView.check(@emailThread)

            @folderID = "test"
            TuringEmailApp.moveToFolderClicked(@folderID)

          afterEach ->
            @moveToFolderSpy.restore()

          it "moves the checked email threads to the folder", ->
            expect(@moveToFolderSpy).toHaveBeenCalledWith([@emailThread.get("uid")], @folderID)

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
          @server.restore()
          [@listViewDiv, @listView, @emailThreads, @server] = specCreateEmailThreadsListView()
    
          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = _.values(@listView.listItemViews)[0].model

          TuringEmailApp.views.emailThreadsListView.select @emailThread

        it "shows the email editor with the selected email thread", ->
          spy = sinon.spy(TuringEmailApp, "showEmailEditorWithEmailThread")
          TuringEmailApp.replyClicked()
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(@emailThread.get("uid"), "reply")
          spy.restore()

      describe "#forwardClicked", ->
        beforeEach ->
          @server.restore()
          [@listViewDiv, @listView, @emailThreads, @server] = specCreateEmailThreadsListView()
    
          TuringEmailApp.views.emailThreadsListView = @listView
          TuringEmailApp.collections.emailThreads = @emailThreads

          @emailThread = _.values(@listView.listItemViews)[0].model

          TuringEmailApp.views.emailThreadsListView.select @emailThread

        it "shows the email editor with the selected email thread", ->
          spy = sinon.spy(TuringEmailApp, "showEmailEditorWithEmailThread")
          TuringEmailApp.forwardClicked()
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(@emailThread.get("uid"), "forward")
          spy.restore()
        
      describe "#archiveClicked", ->
        beforeEach ->
          @server.restore()
          [@listViewDiv, @listView, @emailThreads, @server] = specCreateEmailThreadsListView()

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
            @removeFromFolderSpy = sinon.spy(@emailThread, "removeFromFolder")

            @listView.select(@emailThread)

            @folderID = "test"
            TuringEmailApp.archiveClicked(@folderID)

          afterEach ->
            @removeFromFolderSpy.restore()

          it "remove the selected email thread from the selected folder", ->
            expect(@removeFromFolderSpy).toHaveBeenCalledWith(@folderID)

        describe "when an email thread is checked", ->
          beforeEach ->
            @removeFromFolderSpy = sinon.spy(TuringEmailApp.Models.EmailThread, "removeFromFolder")

            @listView.check(@emailThread)

            @folderID = "test"
            TuringEmailApp.archiveClicked()

          afterEach ->
            @removeFromFolderSpy.restore()

          it "removed the checked email threads from the selected folder", ->
            expect(@removeFromFolderSpy).toHaveBeenCalledWith([@emailThread.get("uid")], @folderID)

      describe "#trashClicked", ->
        beforeEach ->
          @server.restore()
          [@listViewDiv, @listView, @emailThreads, @server] = specCreateEmailThreadsListView()

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
            @trashSpy = sinon.spy(@emailThread, "trash")

            @listView.select(@emailThread)

            @folderID = "test"
            TuringEmailApp.trashClicked(@folderID)

          afterEach ->
            @trashSpy.restore()

          it "trash the selected email", ->
            expect(@trashSpy).toHaveBeenCalled()

        describe "when an email thread is checked", ->
          beforeEach ->
            @trashSpy = sinon.spy(TuringEmailApp.Models.EmailThread, "trash")

            @listView.check(@emailThread)

            @folderID = "test"
            TuringEmailApp.trashClicked()

          afterEach ->
            @trashSpy.restore()

          it "trash the checked email threads", ->
            expect(@trashSpy).toHaveBeenCalledWith([@emailThread.get("uid")])

    describe "#listItemSelected", ->
      beforeEach ->
        @server.restore()
        [@listViewDiv, @listView, @emailThreads, @server] = specCreateEmailThreadsListView()
  
        TuringEmailApp.views.emailThreadsListView = @listView
        TuringEmailApp.collections.emailThreads = @emailThreads
  
        @listItemView = _.values(@listView.listItemViews)[0]
  
      afterEach ->
        @listViewDiv.remove()
  
      describe "when the email is a draft", ->
        describe "when the current folder is NOT the drafts folder", ->
          it "navigates to the email thread", ->
            spy = sinon.spy(TuringEmailApp.routers.emailThreadsRouter, "navigate")
            TuringEmailApp.listItemSelected @listView, @listItemView
            expect(spy).toHaveBeenCalled()
            expect(spy).toHaveBeenCalledWith("#email_thread/" + @listItemView.model.get("uid"))
            spy.restore()

        describe "when the current folder IS the drafts folder", ->
          beforeEach ->
            @server.restore()
            [@server] = specPrepareEmailFoldersFetch(TuringEmailApp.collections.emailFolders)
            TuringEmailApp.collections.emailFolders.fetch(reset: true)
            @server.respond()
            
            @emailFolder = TuringEmailApp.collections.emailFolders.getEmailFolder("DRAFT")
            @stub = sinon.stub(TuringEmailApp, "selectedEmailFolder")
            @stub.returns(@emailFolder)
            
          afterEach ->
            @stub.restore()
            
          it "navigates to the email draft", ->
            spy = sinon.spy(TuringEmailApp.routers.emailThreadsRouter, "navigate")
            TuringEmailApp.listItemSelected @listView, @listItemView
            expect(spy).toHaveBeenCalled()
            expect(spy).toHaveBeenCalledWith("#email_draft/" + @listItemView.model.get("uid"))
            spy.restore()
  
      describe "when the email is not draft", ->
        beforeEach ->
          @listView.listItemViews[@listItemView.model.get("uid")].model.get("emails")[0].draft_id = null
  
        it "navigates to the email thread", ->
          spy = sinon.spy(TuringEmailApp.routers.emailThreadsRouter, "navigate")
          TuringEmailApp.listItemSelected @listView, @listItemView
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith("#email_thread/" + @listItemView.model.get("uid"))
          spy.restore()
  
    describe "#listItemDeselected", ->
      it "navigates to the email thread url", ->
        spy = sinon.spy(TuringEmailApp.routers.emailThreadsRouter, "navigate")
        TuringEmailApp.listItemDeselected null, null
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith("#email_thread/.")
        spy.restore()
  
    describe "#listItemChecked", ->
  
      beforeEach ->
        @server.restore()
        [@server] = specPrepareEmailThreadsFetch(TuringEmailApp.collections.emailThreads)
        TuringEmailApp.collections.emailThreads.fetch(reset: true)
        @server.respond()
        emailThread = TuringEmailApp.collections.emailThreads.models[0]
        TuringEmailApp.showEmailThread emailThread
  
      it "hides the current email thread view.", ->
        spy = sinon.spy(TuringEmailApp.currentEmailThreadView.$el, "hide")
        TuringEmailApp.listItemChecked null, null
        expect(spy).toHaveBeenCalled()
        spy.restore()
  
    describe "#listItemUnchecked", ->
  
      describe "when there is a current email thread view", ->
        beforeEach ->
          @server.restore()
          [@server] = specPrepareEmailThreadsFetch(TuringEmailApp.collections.emailThreads)
          TuringEmailApp.collections.emailThreads.fetch(reset: true)
          @server.respond()
          emailThread = TuringEmailApp.collections.emailThreads.models[0]
          TuringEmailApp.showEmailThread emailThread
  
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
        [@server] = specPrepareUserSettingsFetch()
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
                
    describe "#moveTuringEmailReportToTop", ->
      beforeEach ->
        @server.restore()
  
        [@listViewDiv, emailThreadsListView, emailThreads, @server] = specCreateEmailThreadsListView()
        TuringEmailApp.views.emailThreadsListView = emailThreadsListView
  
  
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
  
    describe "#showEmails", ->
      beforeEach ->
        @showEmailsSpy = sinon.spy(TuringEmailApp.views.mainView, "showEmails")
        
        TuringEmailApp.showEmails()
        
      afterEach ->
        @showEmailsSpy.restore()
        
      it "shows the emails on the main view", ->
        expect(@showEmailsSpy).toHaveBeenCalledWith(TuringEmailApp.isSplitPaneMode())
        
    describe "#showSettings", ->
      beforeEach ->
        @showSettingsSpy = sinon.spy(TuringEmailApp.views.mainView, "showSettings")

        [@server] = specPrepareUserSettingsFetch()
        TuringEmailApp.models.userSettings.fetch()
        @server.respond()

        TuringEmailApp.showSettings()

      afterEach ->
        @showSettingsSpy.restore()

      it "shows the Settings on the main view", ->
        expect(@showSettingsSpy).toHaveBeenCalled()

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

        TuringEmailApp.showReport(undefined, TuringEmailApp.Models.AttachmentsReport,
                                  TuringEmailApp.Views.Reports.AttachmentsReportView)

      afterEach ->
        @showReportSpy.restore()

      it "shows the Analytics on the main view", ->
        expect(@showReportSpy).toHaveBeenCalled()
