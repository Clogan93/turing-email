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
    
  describe "#render", ->
    beforeEach ->
      @resizeSpy = sinon.spy(@mainView, "resize")
      @mainView.render()
      
    afterEach ->
      @resizeSpy.restore()
      
    it "creates the primary_pane", ->
      expect(@mainView.primaryPaneDiv).toBeDefined()
      
    it "creates the sidebar view", ->
      expect(@mainView.sidebarView).toBeDefined()

    it "creates the footer view", ->
      expect(@mainView.footerView).toBeDefined()

    it "creates the compose view", ->
      expect(@mainView.composeView).toBeDefined()
      
    it "resized", ->
      expect(@resizeSpy).toHaveBeenCalled()
            
  describe "#createEmailThreadsListView", ->
    beforeEach ->
      @server.restore()
      
      [@server] = specPrepareEmailThreadsFetch()
      @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()
      @emailThreads.fetch()
      @server.respond()
      
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
        @resizeSplitPaneSpy = sinon.stub(@mainView, "resizeSplitPane", ->)

        @mainView.resize()
        
      afterEach ->
        @sidebarResizeSpy.restore()
        @resizePrimaryPaneSpy.restore()
        @resizeSplitPaneSpy.restore()
      
      it "resizes the sidebar", ->
        expect(@sidebarResizeSpy).toHaveBeenCalled()

      it "resizes the primary pane", ->
        expect(@resizePrimaryPaneSpy).toHaveBeenCalled()

      it "resizes the split pane", ->
        expect(@resizeSplitPaneSpy).toHaveBeenCalled()
      
  describe "after render and createEmailThreadsListView", ->
    beforeEach ->
      @mainView.render()

      @server.restore()

      [@server] = specPrepareEmailThreadsFetch()
      @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()
      @emailThreads.fetch()
      @server.respond()

      @mainView.createEmailThreadsListView(@emailThreads)
      
      @primaryPane = @mainView.$el.find(".primary_pane")
    
    describe "View Functions", ->
      describe "#showEmails", ->
        describe "without split pane", ->
          beforeEach ->
            @resizeSplitPaneSpy = sinon.spy(@mainView, "resizeSplitPane")
            
            @mainView.showEmails(false)
            
          afterEach ->
            @resizeSplitPaneSpy.restore()
            
          it "shows the email controls", ->
            expect(@primaryPane.children().length).toEqual(2)
            expect($(@primaryPane.children()[0])).toHaveClass("toolbar")
            expect($(@primaryPane.children()[1])).toHaveClass("email_threads_list_view")

        describe "with split pane", ->
          beforeEach ->
            @mainView.showEmails(true)

          it "shows the email controls", ->
            expect(@primaryPane.children().length).toEqual(2)
            expect($(@primaryPane.children()[0])).toHaveClass("toolbar")
            expect($(@primaryPane.children()[1])).toHaveClass("split_pane")
            
            splitPane = $(@primaryPane.children()[1])
            expect(splitPane.children().length).toEqual(3)
            
            expect(splitPane.children()[0]).toHaveClass("email_threads_list_view")
            expect(splitPane.children()[1]).toHaveClass("email_thread_view")
            expect(splitPane.children()[2]).toHaveClass("ui-layout-resizer-south")

      describe "#showSettings", ->
        beforeEach ->
          @server.restore()
  
          [@server] = specPrepareUserSettingsFetch()
          TuringEmailApp.models.userSettings.fetch()
          @server.respond()
          
          @settingsView = @mainView.showSettings()
  
        it "shows the settings view", ->
          expect(@primaryPane.children().length).toEqual(1)
          expect($(@primaryPane.children()[0]).html()).toEqual(@settingsView.$el.html())
  
      describe "#showAnalytics", ->
        beforeEach ->
          @analyticsView = @mainView.showAnalytics()
  
        it "shows the analytics view", ->
          expect(@primaryPane.children().length).toEqual(1)
          expect($(@primaryPane.children()[0]).html()).toEqual(@analyticsView.$el.html())
  
      describe "#showReport", ->
        beforeEach ->
          @reportView = @mainView.showReport(undefined, TuringEmailApp.Models.AttachmentsReport,
                                             TuringEmailApp.Views.Reports.AttachmentsReportView)
  
        it "shows the report view", ->
          expect(@primaryPane.children().length).toEqual(1)
          expect($(@primaryPane.children()[0]).html()).toEqual(@reportView.$el.html())
  
      describe "#showEmailThread", ->
        beforeEach ->
          @server.restore()
          [@server, @emailThread] = specPrepareEmailThreadFetch()
          @emailThread.fetch()
          @server.respond()      
          
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
