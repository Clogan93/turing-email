describe "AppsCollection", ->
  beforeEach ->
    @appsCollection = new TuringEmailApp.Collections.AppsCollection()

  it "uses the App model", ->
    expect(@appsCollection.model).toEqual(TuringEmailApp.Models.App)

  it "has the right URL", ->
    expect(@appsCollection.url).toEqual("/api/v1/apps")

  describe "with models", ->
    beforeEach ->
      @appsCollection.add(FactoryGirl.createLists("App", FactoryGirl.SMALL_LIST_SIZE))

    describe "Events", ->
      describe "#modelRemoved", ->
        beforeEach ->
          @app = @appsCollection.at(0)
          @triggerStub = sinon.spy(@app, "trigger")

          @appsCollection.remove(@app)

        afterEach ->
          @triggerStub.restore()

        it "triggers removedFromCollection on the app", ->
          expect(@triggerStub).toHaveBeenCalledWith("removedFromCollection", @appsCollection)

      describe "#modelsReset", ->
        beforeEach ->
          @modelRemovedStub = sinon.stub(@appsCollection, "modelRemoved", ->)

          @oldApps = @appsCollection.models
          @apps = FactoryGirl.createLists("App", FactoryGirl.SMALL_LIST_SIZE)
          @appsCollection.reset(@apps)

        afterEach ->
          @modelRemovedStub.restore()

        it "calls modelRemoved for each model model removed", ->
          for app in @oldApps
            expect(@modelRemovedStub).toHaveBeenCalledWith(app)
