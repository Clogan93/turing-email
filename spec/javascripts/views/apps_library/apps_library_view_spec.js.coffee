describe "AppsLibrary", ->
  beforeEach ->
    specStartTuringEmailApp()

    @apps = new TuringEmailApp.Collections.AppsCollection(FactoryGirl.createLists("App", FactoryGirl.SMALL_LIST_SIZE))
    @appsLibraryView = new TuringEmailApp.Views.AppsLibrary.AppsLibraryView(collection: @apps)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@appsLibraryView.template).toEqual JST["backbone/templates/apps_library/apps_library"]

  describe "#initialize", ->
    describe "Collection Event Hooks", ->
      beforeEach ->
        @renderStub = sinon.stub(@appsLibraryView, "render")
        
      afterEach ->
        @renderStub.restore()
        
      describe "#add", ->
        beforeEach ->
          @apps.add(FactoryGirl.create("App"))
          
        afterEach ->
          @apps.reset()
        
        it "calls render", ->
          expect(@renderStub).toHaveBeenCalled()

      describe "#remove", ->
        beforeEach ->
          @apps.remove(@apps.at(0))

        afterEach ->
          @apps.reset()

        it "calls render", ->
          expect(@renderStub).toHaveBeenCalled()

      describe "#reset", ->
        beforeEach ->
          @apps.reset()

        afterEach ->
          @apps.reset()

        it "calls render", ->
          expect(@renderStub).toHaveBeenCalled()

      describe "#destroy", ->
        beforeEach ->
          @server = sinon.fakeServer.create()
          @apps.at(0).destroy()

        afterEach ->
          @apps.reset()
          @server.restore()

        it "calls render", ->
          expect(@renderStub).toHaveBeenCalled()
  
  describe "#render", ->
    beforeEach ->
      @setupButtonsStub = sinon.stub(@appsLibraryView, "setupButtons")

      @appsLibraryView.render()
      
    afterEach ->
      @setupButtonsStub.restore()
      
    it "calls setupButtons", ->
      expect(@setupButtonsStub).toHaveBeenCalled()
  
  describe "after render", ->
    beforeEach ->
      @appsLibraryView.render()
      
    describe "#setupButtons", ->
      beforeEach ->
        @onCreateAppButtonClickStub = sinon.stub(@appsLibraryView, "onCreateAppButtonClick")
        @onInstallAppButtonClickStub = sinon.stub(@appsLibraryView, "onInstallAppButtonClick")
        
        @appsLibraryView.setupButtons()
        
      afterEach ->
        @onInstallAppButtonClickStub.restore()
        @onCreateAppButtonClickStub.restore()

      it "creates the create app view", ->
        expect(@appsLibraryView.createAppView).toBeDefined()
        
      it "renders the create app view", ->
        expect(@appsLibraryView.$el.find(".create_app_view").html()).toEqual(@appsLibraryView.createAppView.$el.html())
        
      it "handles create_app_button click", ->
        expect(@appsLibraryView.$el.find(".create_app_button")).toHandle("click")
        
      it "create_app_button click", ->
        @appsLibraryView.$el.find(".create_app_button").click()
        expect(@onCreateAppButtonClickStub).toHaveBeenCalled()
        
      it "handles install_app_button click", ->
        expect(@appsLibraryView.$el.find(".install_app_button")).toHandle("click")

      it "install_app_button click", ->
        @appsLibraryView.$el.find(".install_app_button").click()
        expect(@onInstallAppButtonClickStub).toHaveBeenCalled()

    describe "after setupButtons", ->
      beforeEach ->
        @appsLibraryView.setupButtons()

      describe "#onCreateAppButtonClick", ->
        beforeEach ->
          @showStub = sinon.stub(@appsLibraryView.createAppView, "show")

          @appsLibraryView.onCreateAppButtonClick()
          
        afterEach ->
          @showStub.restore()
        
        it "shows the app view", ->
          expect(@showStub).toHaveBeenCalled()

      describe "#onInstallAppButtonClick", ->
        beforeEach ->
          @server = sinon.fakeServer.create()
          @clock = sinon.useFakeTimers()
        
          @event =
            currentTarget: $(@appsLibraryView.$el.find(".install_app_button")[0])

          @alertToken = {}
          @showAlertStub = sinon.stub(TuringEmailApp, "showAlert", => @alertToken)
          @removeAlertStub = sinon.stub(TuringEmailApp, "removeAlert")

          @appsLibraryView.onInstallAppButtonClick(@event)

        afterEach ->
          @clock.restore()
          @server.restore()

          @removeAlertStub.restore()
          @showAlertStub.restore()
          
        it "posts the install request", ->
          expect(@server.requests.length).toEqual 1

          request = @server.requests[0]
          expect(request.method).toEqual("POST")
          expect(request.url).toEqual("/api/v1/apps/install/" + @apps.at(0).get("uid"))
          expect(request.requestBody).toEqual(null)
          
        it "shows the alert", ->
          expect(@showAlertStub).toHaveBeenCalledWith("You have installed the app!", "alert-success")
  
        it "removes the alert after three seconds", ->
          @clock.tick(2999)
          expect(@removeAlertStub).not.toHaveBeenCalled()
  
          @clock.tick(1);
          expect(@removeAlertStub).toHaveBeenCalledWith(@alertToken)
