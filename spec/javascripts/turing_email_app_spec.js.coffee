describe "TuringEmailApp", ->
  beforeEach ->
    @server = sinon.fakeServer.create()

  it "has the app objects defined", ->
    expect(TuringEmailApp.Models).toBeDefined()
    expect(TuringEmailApp.Views).toBeDefined()
    expect(TuringEmailApp.Collections).toBeDefined()
    expect(TuringEmailApp.Routers).toBeDefined()
    
  describe "#start", ->
    beforeEach ->
      setupFunctions = ["setupSearchBar", "setupComposeButton", "setupToolbar", "setupUser",
                        "setupEmailFolders", "loadEmailFolders", "setupComposeView", "setupEmailThreads", "setupRouters"]
      @spies = []
      for setupFunction in setupFunctions
        @spies.push(sinon.spy(TuringEmailApp, setupFunction))

      TuringEmailApp.start()
      
    afterEach ->
      for spy in @spies
        spy.restore()

    it "defines the model, view, collection, and router containers", ->
      expect(TuringEmailApp.models).toBeDefined()
      expect(TuringEmailApp.views).toBeDefined()
      expect(TuringEmailApp.collections).toBeDefined()
      expect(TuringEmailApp.routers).toBeDefined()
      
    it "calls the setup functions", ->
      for spy in @spies
        expect(spy).toHaveBeenCalled()
        
    it "starts the backbone history", ->
      expect(Backbone.History.started).toBeTruthy()
      
  describe "#startEmailSync", ->
    beforeEach ->
      @spy = sinon.spy(window, "setInterval")
      TuringEmailApp.startEmailSync()
      
    afterEach ->
      @spy.restore()
    
    it "creates the sync email interval", ->
      expect(@spy).toHaveBeenCalledWith(TuringEmailApp.syncEmail, 60000)

  describe "#setupSearchBar", ->
    beforeEach ->
      @divSearchForm = $('<form role="search" id="top-search-form" class="navbar-form-custom"></form>').appendTo("body")
      
      TuringEmailApp.setupSearchBar()
     
    afterEach ->
      @divSearchForm.remove()

    it "hooks the header search form submit action", ->
      expect(@divSearchForm).toHandle("submit")
     
    it "prevents the default form action", ->
      selector = "#" + @divSearchForm.attr("id")
      spyOnEvent(selector, "submit")
      
      @divSearchForm.submit()
      
      expect("submit").toHaveBeenPreventedOn(selector)
      
    it "searches on submit", ->
      @spy = sinon.spy(TuringEmailApp, "searchClicked")
      
      @divSearchForm.submit()
      
      expect(@spy).toHaveBeenCalled()
      @spy.restore()

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