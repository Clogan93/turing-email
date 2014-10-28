describe "App", ->
  beforeEach ->
    @app = new TuringEmailApp.Models.App(FactoryGirl.create("App"))

    it "uses uid as idAttribute", ->
      expect(@app.idAttribute).toEqual("uid")
