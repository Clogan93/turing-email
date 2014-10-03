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

    setupFunctions = ["setupSearchBar", "setupComposeButton", "setupToolbar", "setupUser",
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

  describe "#setupFiltering", ->
    beforeEach ->
      @createFilterDiv = $('<div class="create_filter"><div />').appendTo("body")
      @filterFormDiv = $('<div id="filter_form"><div />').appendTo("body")
      @dropdownDiv = $('<div class="dropdown"><a href="#"></a></div>').appendTo("body")
      TuringEmailApp.setupFiltering()

    it "binds the click event to save button", ->
      expect($(".create_filter")).toHandle("click")

    describe "when the create filter link is clicked", ->

      it "triggers the click.bs.dropdown event on the dropdown a tag", ->
        spyEvent = spyOnEvent('.dropdown a', 'click.bs.dropdown')
        $('.create_filter').click()
        expect('click.bs.dropdown').toHaveBeenTriggeredOn('.dropdown a')
        expect(spyEvent).toHaveBeenTriggered()

    it "binds the submit event to the filter form", ->
      expect($("#filter_form")).toHandle("submit")

    describe "when the filter form is submitted", ->

      it "should post the email rule to the server", ->
        $("#filter_form").submit()
        expect(@server.requests.length).toEqual 4
        request = @server.requests[0]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "/api/v1/genie_rules.json"

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