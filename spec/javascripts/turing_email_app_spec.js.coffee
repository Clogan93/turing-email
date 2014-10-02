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