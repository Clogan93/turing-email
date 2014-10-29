describe "CreateAppView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @createAppDiv = $("<div class='create_app_view'></div>").appendTo("body")
    @createAppView = new TuringEmailApp.Views.AppsLibrary.CreateAppView(
      app: TuringEmailApp
      el: $(".create_app_view")
    )

  afterEach ->
    @createAppDiv.remove()
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@createAppView.template).toEqual JST["backbone/templates/apps_library/create_app"]
    
  describe "#render", ->
    beforeEach ->
      @setupViewStub = sinon.stub(@createAppView, "setupView")

      @createAppView.render()
      
    afterEach ->
      @setupViewStub.restore()
    
    it "calls setupView", ->
      expect(@setupViewStub).toHaveBeenCalled()

  describe "after render", ->
    beforeEach ->
      @createAppView.render()

    describe "#setupView", ->
      it "binds the submit event of create-app-form", ->
        expect(@createAppView.$el.find(".create-app-form")).toHandle("submit")

    describe "#show", ->
      beforeEach ->
        @dropdownSpy = spyOnEvent('.dropdown a', 'click.bs.dropdown')
        @createAppView.show()

      it "triggers the click.bs.dropdown event on the dropdown link", ->
        expect("click.bs.dropdown").toHaveBeenTriggeredOn(".dropdown a")

    describe "#hide", ->
      beforeEach ->
        @dropdownSpy = spyOnEvent('.dropdown a', 'click.bs.dropdown')
        @createAppView.hide()

      it "triggers the click.bs.dropdown event on the dropdown link", ->
        expect("click.bs.dropdown").toHaveBeenTriggeredOn(".dropdown a")

    describe "#resetView", ->
      beforeEach ->
        @createAppView.$el.find(".create-app-form .create-app-name").val("Name")
        @createAppView.$el.find(".create-app-form .create-app-description").val("Desc")
        @createAppView.$el.find(".create-app-form .create-app-type").val("Type")
        @createAppView.$el.find(".create-app-form .create-app-callback-url").val("Callback")

        @createAppView.resetView()
    
      it "clears the create rule view input fields", ->
        expect(@createAppView.$el.find(".create-app-form .create-app-name").val()).toEqual("")
        expect(@createAppView.$el.find(".create-app-form .create-app-description").val()).toEqual("")
        expect(@createAppView.$el.find(".create-app-form .create-app-type").val()).toEqual("")
        expect(@createAppView.$el.find(".create-app-form .create-app-callback-url").val()).toEqual("")

    describe "#onSubmit", ->
      beforeEach ->
        @createAppView.$el.find(".create-app-form .create-app-name").val("Name")
        @createAppView.$el.find(".create-app-form .create-app-description").val("Desc")
        @createAppView.$el.find(".create-app-form .create-app-type").val("Type")
        @createAppView.$el.find(".create-app-form .create-app-callback-url").val("Callback")
        
        @server = sinon.fakeServer.create()
        @clock = sinon.useFakeTimers()
        
        @resetViewStub = sinon.stub(@createAppView, "resetView")
        @hideStub = sinon.stub(@createAppView, "hide")

        @alertToken = {}
        @showAlertStub = sinon.stub(TuringEmailApp, "showAlert", => @alertToken)
        @removeAlertStub = sinon.stub(TuringEmailApp, "removeAlert")

        @createAppView.onSubmit()

      afterEach ->
        @clock.restore()
        @server.restore()
        
        @removeAlertStub.restore()
        @showAlertStub.restore()
        @hideStub.restore()
        @resetViewStub.restore()
        
        @createAppView.resetView()

      it "posts the create app request", ->
        expect(@server.requests.length).toEqual 1
        
        request = @server.requests[0]
        expect(request.method).toEqual("POST")
        expect(request.url).toEqual("/api/v1/apps")
        
        expect(request.requestBody).toEqual("name=Name&description=Desc&app_type=Type&callback_url=Callback")

      it "shows the alert", ->
        expect(@showAlertStub).toHaveBeenCalledWith("You have successfully created the app!", "alert-success")

      it "removes the alert after three seconds", ->
        @clock.tick(2999)
        expect(@removeAlertStub).not.toHaveBeenCalled()

        @clock.tick(1);
        expect(@removeAlertStub).toHaveBeenCalledWith(@alertToken)

      it "resets the view", ->
        expect(@resetViewStub).toHaveBeenCalled()

      it "hides the view", ->
        expect(@hideStub).toHaveBeenCalled()
