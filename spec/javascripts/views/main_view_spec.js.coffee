describe "MainView", ->
  beforeEach ->
    specStartTuringEmailApp()
    @mainView = TuringEmailApp.views.mainView
    
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()
    
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@mainView.template).toEqual JST["backbone/templates/main"]

  it "saves the app initialization parameter", ->
    expect(@mainView.app).toEqual(TuringEmailApp)
    
  describe "#render", ->
    beforeEach ->
      @mainView.render()
      
    it "creates the sidebar view", ->
      expect(@mainView.sidebarView).toBeDefined()

    it "creates the footer view", ->
      expect(@mainView.footerView).toBeDefined()

    it "creates the toolbar view", ->
      expect(@mainView.toolbarView).toBeDefined()

    it "creates the compose view", ->
      expect(@mainView.composeView).toBeDefined()

    it "creates the create folder view", ->
      expect(@mainView.createFolderView).toBeDefined()

  describe "#createEmailThreadsListView", ->
    beforeEach ->
      @server.restore()
      
      [@server] = specPrepareEmailThreadsFetch()
      @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()
      @emailThreads.fetch()
      @server.respond()
      
      #@mainView.createEmailThreadsListView(@emailThreads)
    
    it "creates the emailThreadsListView", ->
      #expect(@mainView.emailThreadsListView).toBeDefined()
  
  describe "after render and createEmailThreadsListView", ->
    beforeEach ->
      @mainView.render()

      @server.restore()

      [@server] = specPrepareEmailThreadsFetch()
      @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()
      @emailThreads.fetch()
      @server.respond()

      @mainView.createEmailThreadsListView(@emailThreads)
      
      @primaryPane = @mainView.$el.find("#primary_pane")
      
    describe "#showEmails", ->
      beforeEach ->
        @mainView.showEmails()
        
      it "shows the email controls", ->
        expect(@primaryPane.children().length).toEqual(2)
        expect($(@primaryPane.children()[0]).attr("id")).toEqual("email-folder-mail-header")
        expect($(@primaryPane.children()[1]).attr("name")).toEqual("email_threads_list_view")

    describe "#showSettings", ->
      beforeEach ->
        @server.restore()

        [@server] = specPrepareUserSettingsFetch()
        TuringEmailApp.models.userSettings.fetch()
        @server.respond()
        
        @settingsView = @mainView.showSettings()

      it "shows the settings view", ->
        expect(@primaryPane.html()).toEqual(@settingsView.$el.html())

    describe "#showAnalytics", ->
      beforeEach ->
        @analyticsView = @mainView.showAnalytics()

      it "shows the analytics view", ->
        expect(@primaryPane.html()).toEqual(@analyticsView.$el.html())

    describe "#showReport", ->
      beforeEach ->
        @reportView = @mainView.showReport(undefined, TuringEmailApp.Models.AttachmentsReport,
                                           TuringEmailApp.Views.Reports.AttachmentsReportView)

      it "shows the report view", ->
        expect(@primaryPane.html()).toEqual(@reportView.$el.html())

    describe "#showEmailThread", ->
      beforeEach ->
        @server.restore()
        [@server, @emailThread] = specPrepareEmailThreadFetch()
        @emailThread.fetch()
        @server.respond()      
        
      describe "when split pane mode is on", ->
        beforeEach ->
          @emailThreadView = TuringEmailApp.views.mainView.showEmailThread(@emailThread, true)
          
        it "shows the preview panel element", ->
          expect($("#preview_panel")).toBeVisible()

        it "renders the email thread in the preview panel", ->
          expect(@emailThreadView.$el).toEqual $("#preview_content")

      describe "when split pane mode is off", ->
        beforeEach ->
          @emailThreadView = TuringEmailApp.views.mainView.showEmailThread(@emailThread, false)

        it "shows the preview panel element", ->
          expect($("#preview_panel")).not.toBeVisible()

        it "renders the email thread in the preview panel", ->
          expect(@emailThreadView.$el).toEqual $("#primary_pane")
