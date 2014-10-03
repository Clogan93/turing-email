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
      
    describe "getters", ->
      describe "#selectedEmailThread", ->
        beforeEach ->
          @server.restore()
          emailThreadFixtures = fixture.load("email_thread.fixture.json")
          validEmailThreadFixture = emailThreadFixtures[0]["valid"]
          @server = sinon.fakeServer.create()

          @emailThread = new TuringEmailApp.Models.EmailThread(undefined, emailThreadUID: validEmailThreadFixture["uid"])
          @server.respondWith "GET", @emailThread.url, JSON.stringify(validEmailThreadFixture)

          @emailThread.fetch()
          @server.respond()
    
          TuringEmailApp.views.emailThreadsListView.collection.add(@emailThread)
          TuringEmailApp.views.emailThreadsListView.select(@emailThread)
          
        it "returns the selected email thread", ->
          expect(TuringEmailApp.selectedEmailThread()).toEqual(@emailThread)
          
      describe "#selectedEmailFolder", ->
        beforeEach ->
          @server.restore()
          emailFoldersFixtures = fixture.load("email_folders.fixture.json")
          validEmailFoldersFixture = emailFoldersFixtures[0]["valid"]
          @server = sinon.fakeServer.create()

          @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
          @server.respondWith "GET", @emailFolders.url, JSON.stringify(validEmailFoldersFixture)

          @emailFolders.fetch()
          @server.respond()
          
          TuringEmailApp.views.emailFoldersTreeView.select(@emailFolders.models[0])

        it "returns the selected email folder", ->
          expect(TuringEmailApp.selectedEmailFolder()).toEqual(@emailFolders.models[0])

      describe "#selectedEmailFolderID", ->
        beforeEach ->
          @server.restore()
          emailFoldersFixtures = fixture.load("email_folders.fixture.json")
          validEmailFoldersFixture = emailFoldersFixtures[0]["valid"]
          @server = sinon.fakeServer.create()

          @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
          @server.respondWith "GET", @emailFolders.url, JSON.stringify(validEmailFoldersFixture)

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

            emailThreadsFixtures = fixture.load("email_threads.fixture.json");
            validEmailThreadsFixture = emailThreadsFixtures[0]["valid"]

            @server = sinon.fakeServer.create()
            @server.respondWith "GET", TuringEmailApp.collections.emailThreads.url, JSON.stringify(validEmailThreadsFixture)

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

          emailThreadsFixtures = fixture.load("email_threads.fixture.json");
          @validEmailThreadsFixture = emailThreadsFixtures[0]["valid"]

          @server = sinon.fakeServer.create()
          @server.respondWith "GET", TuringEmailApp.collections.emailThreads.url, JSON.stringify(@validEmailThreadsFixture)

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
                TuringEmailApp.isSplitPaneMode = -> return true

                TuringEmailApp.collections.emailThreads.fetch()
                @server.respond()
                @emailThread = TuringEmailApp.collections.emailThreads.models[0]

              it "selects an email thread", ->
                expect(@currentEmailThreadIsSpy).toHaveBeenCalledWith(@emailThread.get("uid"))

            describe "with NO split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return false

                TuringEmailApp.collections.emailThreads.fetch()
                @server.respond()
                @emailThread = TuringEmailApp.collections.emailThreads.models[0]

              it "does NOT selects an email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalledWith(@emailThread.get("uid"))

          describe "with draft", ->
            beforeEach ->
              @validEmailThreadsFixture[0]["emails"][0]["draft_id"] = "1"
              @server.respondWith "GET", TuringEmailApp.collections.emailThreads.url, JSON.stringify(@validEmailThreadsFixture)
              
            describe "with split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return true

                TuringEmailApp.collections.emailThreads.fetch()
                @server.respond()
                @emailThread = TuringEmailApp.collections.emailThreads.models[0]

              it "does NOT selects an email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalledWith(@emailThread.get("uid"))

            describe "with NO split pane", ->
              beforeEach ->
                TuringEmailApp.isSplitPaneMode = -> return false

                TuringEmailApp.collections.emailThreads.fetch()
                @server.respond()
                @emailThread = TuringEmailApp.collections.emailThreads.models[0]

              it "does NOT selects an email thread", ->
                expect(@currentEmailThreadIsSpy).not.toHaveBeenCalledWith(@emailThread.get("uid"))

    describe "#syncEmail", ->
      beforeEach ->
        TuringEmailApp.syncEmail()

        @reloadEmailThreadsSpy = sinon.spy(TuringEmailApp, "reloadEmailThreads")
        
      afterEach ->
        @reloadEmailThreadsSpy.restore()
        
      it "posts the sync email request", ->
        expect(@server.requests.length).toEqual 4

        request = @server.requests[3]
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

  ###
  describe "#moveTuringEmailReportToTop", ->
  
    describe "if there is a report email", ->
  
      beforeEach ->
        @turingEmailThread = _.values(@listView.listItemViews)[0].model
  
        @listView.collection.remove @turingEmailThread
        @turingEmailThread.get("emails")[0].from_name = "Turing Email"
        @listView.collection.add @turingEmailThread
  
      it "should move the email to the top", ->
        expect($("#email_table_body").children()[0]).not.toContainText("Turing Email")
  
        @listView.moveTuringEmailReportToTop()
  
        expect($("#email_table_body").children()[0]).toContainText("Turing Email")
  
    describe "if there is not a report email", ->
  
      it "should leave the emails in the same order", ->
        emailTableBodyBefore = $("#email_table_body")
        @listView.moveTuringEmailReportToTop()
        emailTableBodyAfter = $("#email_table_body")
  
        expect(emailTableBodyBefore).toEqual emailTableBodyAfter
  ###