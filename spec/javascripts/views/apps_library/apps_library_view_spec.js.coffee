describe "AppsLibrary", ->
  beforeEach ->
    specStartTuringEmailApp()

    @apps = new TuringEmailApp.Collections.AppsCollection(FactoryGirl.createLists("App", FactoryGirl.SMALL_LIST_SIZE))
    @appsLibraryView = new TuringEmailApp.Views.AppsLibrary.AppsLibraryView(collection: @apps, developer_enabled: true)

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
      
    describe "developer_enabled=true", ->
      beforeEach ->
        @appsLibraryView.render()
        
      it "renders the create button", ->
        expect(@appsLibraryView.$el.find(".create-app-button").length).toEqual(1)
      
    describe "developer_enabled=false", ->
      beforeEach ->
        @appsLibraryView.developer_enabled = false
        @appsLibraryView.render()

      it "does NOT render the create button", ->
        expect(@appsLibraryView.$el.find(".create-app-button").length).toEqual(0)
        
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
        
      it "handles create-app-button click", ->
        expect(@appsLibraryView.$el.find(".create-app-button")).toHandle("click")
        
      it "create-app-button click", ->
        @appsLibraryView.$el.find(".create-app-button").click()
        expect(@onCreateAppButtonClickStub).toHaveBeenCalled()
        
      it "handles install-app-button click", ->
        expect(@appsLibraryView.$el.find(".install-app-button")).toHandle("click")

      it "install-app-button click", ->
        @appsLibraryView.$el.find(".install-app-button").click()
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
          @clock = sinon.useFakeTimers()
        
          @event =
            currentTarget: $(@appsLibraryView.$el.find(".install-app-button")[0])

          @alertToken = {}
          @showAlertStub = sinon.stub(TuringEmailApp, "showAlert", => @alertToken)
          @removeAlertStub = sinon.stub(TuringEmailApp, "removeAlert")
          @triggerStub = sinon.stub(@appsLibraryView, "trigger", ->)

          @appsLibraryView.onInstallAppButtonClick(@event)

        afterEach ->
          @clock.restore()

          @removeAlertStub.restore()
          @showAlertStub.restore()
          @triggerStub.restore()

        it "triggers installAppClicked", ->
          expect(@triggerStub).toHaveBeenCalledWith("installAppClicked", @appsLibraryView, @apps.at(0).get("uid"))
          
        it "shows the alert", ->
          expect(@showAlertStub).toHaveBeenCalledWith("You have installed the app!", "alert-success")
  
        it "removes the alert after three seconds", ->
          @clock.tick(2999)
          expect(@removeAlertStub).not.toHaveBeenCalled()
  
          @clock.tick(1);
          expect(@removeAlertStub).toHaveBeenCalledWith(@alertToken)
