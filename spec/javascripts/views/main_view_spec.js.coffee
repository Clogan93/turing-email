describe "MainView", ->
  beforeEach ->
    specStartTuringEmailApp()
    @mainView = TuringEmailApp.views.mainView
    
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()
    
    specStopTuringEmailApp()

  describe "#initialize", ->
    it "has the right template", ->
      expect(@mainView.template).toEqual JST["backbone/templates/main"]
  
    it "saves the app initialization parameter", ->
      expect(@mainView.app).toEqual(TuringEmailApp)
      
    it "hooks the window resize event", ->
      expect($(window)).toHandle("resize")
      
    it "creates the toolbar", ->
      expect(@mainView.toolbarView).toBeDefined()

    it "creates the miniature toolbar", ->
      expect(@mainView.miniatureToolbarView).toBeDefined()

  describe "#render", ->
    beforeEach ->
      @clock = sinon.useFakeTimers()
      @resizeSpy = sinon.spy(@mainView, "resize")
      @showTourStub = sinon.stub(@mainView, "showTour")
      @mainView.render()
      
    afterEach ->
      @resizeSpy.restore()
      @showTourStub.restore()
      @clock.restore()
      
    it "creates the primary_pane", ->
      expect(@mainView.primaryPaneDiv).toBeDefined()
      
    it "creates the sidebar view", ->
      expect(@mainView.sidebarView).toBeDefined()

    it "creates the compose view", ->
      expect(@mainView.composeView).toBeDefined()
      
    it "resized", ->
      expect(@resizeSpy).toHaveBeenCalled()

    it "show the tour", ->  
      @clock.tick(5000)
      expect(@showTourStub).toHaveBeenCalled()

    it "creates the create folder view", ->
      expect(@mainView.createFolderView).toBeDefined()

  describe "#createEmailThreadsListView", ->
    beforeEach ->
      @server.restore()
      
      @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
        app: TuringEmailApp
        demoMode: false
      )
      @emailThreads.reset(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE))
      @mainView.createEmailThreadsListView(@emailThreads)
    
    it "creates the emailThreadsListView", ->
      expect(@mainView.emailThreadsListView).toBeDefined()
  
  describe "Resize Functions", ->
    describe "#onWindowResize", ->
      beforeEach ->
        @resizeSpy = sinon.stub(@mainView, "resize", ->)
        
        @mainView.onWindowResize()

      afterEach ->
        @resizeSpy.restore()
        
      it "resizes", ->
        expect(@resizeSpy).toHaveBeenCalled()
        
    describe "#resize", ->
      beforeEach ->
        @sidebarResizeSpy = sinon.stub(@mainView, "resizeSidebar", ->)
        @resizePrimaryPaneSpy = sinon.stub(@mainView, "resizePrimaryPane", ->)
        @resizePrimarySplitPaneSpy = sinon.stub(@mainView, "resizePrimarySplitPane", ->)
        @resizeAppsSplitPaneSpy = sinon.stub(@mainView, "resizeAppsSplitPane", ->)
        @resizeEmailThreadsListViewSpy = sinon.stub(@mainView, "resizeEmailThreadsListView", ->)

        @mainView.resize()

      afterEach ->
        @sidebarResizeSpy.restore()
        @resizePrimaryPaneSpy.restore()
        @resizePrimarySplitPaneSpy.restore()
        @resizeAppsSplitPaneSpy.restore()
        @resizeEmailThreadsListViewSpy.restore()

      it "resizes the sidebar", ->
        expect(@sidebarResizeSpy).toHaveBeenCalled()

      it "resizes the primary pane", ->
        expect(@resizePrimaryPaneSpy).toHaveBeenCalled()

      it "resizes the primary split pane", ->
        expect(@resizePrimarySplitPaneSpy).toHaveBeenCalled()

      it "resizes the apps split pane", ->
        expect(@resizeAppsSplitPaneSpy).toHaveBeenCalled()

      it "resizes the email threads list view pane", ->
        expect(@resizeEmailThreadsListViewSpy).toHaveBeenCalled()

  describe "after render and createEmailThreadsListView", ->
    beforeEach ->
      @mainView.render()

      @server.restore()

      @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
        app: TuringEmailApp
        demoMode: false
      )
      @emailThreads.reset(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE))
      @mainView.createEmailThreadsListView(@emailThreads)

      @primaryPane = @mainView.$el.find(".primary_pane")
    
    describe "View Functions", ->
      describe "#showEmails", ->
        it "resizes the email threads live view", ->
          @resizeEmailThreadsListViewSpy = sinon.stub(@mainView, "resizeEmailThreadsListView", ->)
          @mainView.showEmails(true)
          expect(@resizeEmailThreadsListViewSpy).toHaveBeenCalled()
          @resizeEmailThreadsListViewSpy.restore()

        describe "without split pane", ->
          beforeEach ->
            @resizePrimarySplitPaneSpy = sinon.spy(@mainView, "resizePrimarySplitPane")
            
            @mainView.showEmails(false)
            
          afterEach ->
            @resizePrimarySplitPaneSpy.restore()
            
          it "shows the email controls", ->
            expect(@primaryPane.children().length).toEqual(2)
            expect($(@primaryPane.children()[0])).toHaveClass("toolbar")
            expect($(@primaryPane.children()[1])).toHaveClass("email-threads-list-view")

        describe "with split pane", ->
          beforeEach ->
            @mainView.showEmails(true)

          it "shows the email controls", ->
            expect(@primaryPane.children().length).toEqual(2)
            expect($(@primaryPane.children()[0])).toHaveClass("toolbar")
            expect($(@primaryPane.children()[1])).toHaveClass("primary_split_pane")
            
            splitPane = $(@primaryPane.children()[1])
            expect(splitPane.children().length).toEqual(3)
            
            expect(splitPane.children()[0]).toHaveClass("email-threads-list-view")
            expect(splitPane.children()[1]).toHaveClass("email_thread_view")
            expect(splitPane.children()[2]).toHaveClass("ui-layout-resizer-south")

          it "adds the no conversation selected text when there is no conversation selected", ->
            splitPane = $(@primaryPane.children()[1])
            emailThreadView = splitPane.children()[1]
            expect(emailThreadView).toContainHtml("<div class='email-thread-view-default-text'>No conversations selected</div>")

        describe "when there are no emails in list view's collection", ->
          beforeEach ->
            @mainView.emailThreadsListView.collection =
              new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
                app: TuringEmailApp
                demoMode: false
              )

            @selectedEmailFolderIDStub = sinon.stub(TuringEmailApp, "selectedEmailFolderID")
        
          afterEach ->
            @selectedEmailFolderIDStub.restore()

          it "does not render the email thread list view", ->
            spy = sinon.spy(@mainView.emailThreadsListView, "render")
            @mainView.showEmails(true)
            expect(spy).not.toHaveBeenCalled()
            spy.restore()
            
          describe "when the currently selected folder is the inbox", ->
            beforeEach ->
              @selectedEmailFolderIDStub.returns("INBOX")
              @mainView.showEmails(true)

            it "renders that there are not conversations with that label.", ->
              expect(@mainView.primaryPaneDiv).toContainHtml("<div class='empty-text'>Congratulations on reaching inbox zero!</div>")

          describe "when the currently selected folder is not the inbox", ->
            beforeEach ->
              @selectedEmailFolderIDStub.returns("Label_45")
              @mainView.showEmails(true)
            
            it "renders that there are not conversations with that label.", ->
              expect(@mainView.primaryPaneDiv).toContainHtml("<div class='empty-text'>There are no conversations with this label.</div>")

      describe "#showSettings", ->
        beforeEach ->
          @server.restore()

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

          @settingsView = @mainView.showSettings()
  
        it "shows the settings view", ->
          expect(@primaryPane.children().length).toEqual(2)
          expect($(@primaryPane.children()[1]).html()).toEqual(@settingsView.$el.html())

        it "sets the brain rules on the settings view", ->
          expect(@settingsView.brainRules).toEqual TuringEmailApp.collections.brainRules
    
        it "sets the email rules on the settings view", ->
          expect(@settingsView.emailRules).toEqual TuringEmailApp.collections.emailRules

      describe "#showAppsLibrary", ->
        beforeEach ->
          @appsLibraryView = @mainView.showAppsLibrary()

        it "shows the apps library view", ->
          expect(@primaryPane.children().length).toEqual(1)
          expect($(@primaryPane.children()[0]).html()).toEqual(@appsLibraryView.$el.html())

      describe "#showDelayedEmails", ->
        beforeEach ->
          @delayedEmailsView = @mainView.showDelayedEmails()

        it "shows the apps library view", ->
          expect(@primaryPane.children().length).toEqual(1)
          expect($(@primaryPane.children()[0]).html()).toEqual(@delayedEmailsView.$el.html())

      describe "#showEmailTrackers", ->
        beforeEach ->
          @emailTrackersView = @mainView.showEmailTrackers()

        it "shows the apps library view", ->
          expect(@primaryPane.children().length).toEqual(1)
          expect($(@primaryPane.children()[0]).html()).toEqual(@emailTrackersView.$el.html())

      describe "#showAnalytics", ->
        beforeEach ->
          @server.restore()
          @server = specPrepareReportFetches()
          
          @analyticsView = @mainView.showAnalytics()
          
          @server.respond()
  
        it "shows the analytics view", ->
          expect(@primaryPane.children().length).toEqual(1)
          expect($(@primaryPane.children()[0]).html()).toEqual(@analyticsView.$el.html())
          verifyReportsRendered(@primaryPane)
  
      describe "#showReport", ->
        beforeEach ->
          @reportView = @mainView.showReport(TuringEmailApp.Models.Reports.AttachmentsReport,
                                             TuringEmailApp.Views.Reports.AttachmentsReportView)
  
        it "shows the report view", ->
          expect(@primaryPane.children().length).toEqual(1)
          expect($(@primaryPane.children()[0]).html()).toEqual(@reportView.$el.html())
  
      describe "#showEmailThread", ->
        beforeEach ->
          emailThreadAttributes = FactoryGirl.create("EmailThread")
          emailDraftAttributes = FactoryGirl.create("Email", draft_id: "draft")
          emailThreadAttributes.emails.push(emailDraftAttributes)
          
          @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes.toJSON(),
            app: TuringEmailApp
            emailThreadUID: emailThreadAttributes.uid
            demoMode: false
          ) 
          
        describe "with apps", ->
          beforeEach ->
            TuringEmailApp.models.userConfiguration.set(FactoryGirl.create("UserConfiguration"))
            @oldCurrentEmailThreadView = @mainView.currentEmailThreadView = {}

            @server = sinon.fakeServer.create()
            
            @resizeAppsSplitPaneStub = sinon.stub(@mainView, "resizeAppsSplitPane")
            @runAppsStub = sinon.stub(@mainView, "runApps")
            @stopListeningStub = sinon.stub(@mainView, "stopListening")
            @listenToStub = sinon.stub(@mainView, "listenTo")
            
            @emailThreadView = TuringEmailApp.views.mainView.showEmailThread(@emailThread, true)
            @appsSplitPaneDiv = $(@primaryPane.find(".apps_split_pane"))
            
            @appsDiv = $(@appsSplitPaneDiv.children()[1])
            
          afterEach ->
            @stopListeningStub.restore()
            @listenToStub.restore()
            @runAppsStub.restore()
            @resizeAppsSplitPaneStub.restore()
            @server.restore()

          it "stops listening on the currentEmailThreadView", ->
            expect(@stopListeningStub).toHaveBeenCalledWith(@oldCurrentEmailThreadView)
            
          it "creates the split pane", ->
            expect(@appsSplitPaneDiv).toBeDefined()
            
          it "puts the thread view in the center pane", ->
            expect(@emailThreadView.$el).toHaveClass("ui-layout-center")
            
          it "adds the email thread view to the split pane", ->
            expect(@appsSplitPaneDiv.children()[0]).toEqual(@emailThreadView.$el[0])
          
          it "adds the apps div to the split pane", ->
            expect(@appsDiv[0].nodeName).toEqual("DIV")

          it "puts the apps div in the east pane", ->
            expect(@appsDiv).toHaveClass("ui-layout-east")

          it "runs all the apps", ->
            expect(@runAppsStub).toHaveBeenCalled()
            expect(@runAppsStub.args[0][0].html()).toEqual(@appsDiv.html())
            expect(@runAppsStub.args[0][1]).toEqual(@emailThread)
            
          it "listens for expand:email", ->
            expect(@listenToStub).toHaveBeenCalledWith(@emailThreadView, "expand:email")
            specCompareFunctions(((emailThreadView, emailJSON) => @runApps(appsDiv, emailJSON)), @listenToStub.args[0][2])
            
          it "resizes the apps split pane", ->
            expect(@resizeAppsSplitPaneStub).toHaveBeenCalled()

        describe "without apps", ->
          describe "when split pane mode is on", ->
            beforeEach ->
              @emailThreadView = TuringEmailApp.views.mainView.showEmailThread(@emailThread, true)
              
            it "renders the email thread in the email_thread_view", ->
              emailThreadView = $(@primaryPane.find(".email_thread_view").children()[0])
              expect(emailThreadView.html()).toEqual(@emailThreadView.$el.html())
    
          describe "when split pane mode is off", ->
            beforeEach ->
              @emailThreadView = TuringEmailApp.views.mainView.showEmailThread(@emailThread, false)
    
            it "renders the email thread in the primary pane", ->
              emailThreadView = $(@primaryPane.children()[0])
              expect(emailThreadView.html()).toEqual(@emailThreadView.$el.html())

      describe "#runApps", ->
        beforeEach ->
          TuringEmailApp.models.userConfiguration.set(FactoryGirl.create("UserConfiguration"))
          
          @appsDiv = $("<div />")
          @email = new TuringEmailApp.Models.Email(FactoryGirl.create("Email").toJSON())
          
          @runStub = sinon.stub(TuringEmailApp.Models.InstalledApps.InstalledPanelApp.prototype, "run")
          
          @mainView.runApps(@appsDiv, @email)
          
        afterEach ->
          @runStub.restore()

        it "runs the apps", ->
          expect(@runStub.callCount).toEqual(TuringEmailApp.models.userConfiguration.get("installed_apps").length)

        it "adds the app iframes to the split pane", ->
          expect(@appsDiv.children().length).toEqual(TuringEmailApp.models.userConfiguration.get("installed_apps").length)
              
      describe "#showTour", ->
        beforeEach ->
          @mainView.tour = null
          @mainView.showTour()

        it "create a tour object", ->
          expect(@mainView.tour).toBeDefined()

        it "sets the step attributes on the tour", ->
          expect(@mainView.tour._options.steps[0].element).toEqual ".settings-switch"
          expect(@mainView.tour._options.steps[0].placement).toEqual "right"
          expect(@mainView.tour._options.steps[0].title).toEqual "Welcome to demo mode"
          expect(@mainView.tour._options.steps[0].content).toEqual "Toggle to see your emails after the brain has done it's work vs. normal."

        it "the tour is initialized", ->
          expect(@mainView.tour._inited).toBeTruthy()
