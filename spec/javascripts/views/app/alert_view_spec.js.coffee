describe "AlertView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @classtype = 'testClassType'
    @alertView = new TuringEmailApp.Views.App.AlertView(
      classType: @classtype
      text: "testText"
    )

  afterEach ->
    specStopTuringEmailApp()
    
  it "has the right template", ->
    expect(@alertView.template).toEqual JST["backbone/templates/app/alert"]

  describe "#render", ->
    beforeEach ->
      @alertView.render()
    
    it "adds the classes and styling to the alert view", ->
      expect(@alertView.$el).toHaveClass("text-center")
      expect(@alertView.$el).toHaveClass("alert")
      expect(@alertView.$el).toHaveClass(@classtype)
      expect(@alertView.$el).toHaveAttr("role", "alert")
      expect(@alertView.$el).toHaveAttr("style", "z-index: 2000; margin-bottom: 0px; position: absolute; width: 100%;")

    it "binds a click handler to the dismiss alert link", ->
      expect(@alertView.$el.find(".dismiss-alert-link")).toHandle("click")

    describe "when the dismiss alert link is clicked", ->
      beforeEach ->
        @removeAlertStub = sinon.stub(TuringEmailApp, "removeAlert")
        
      afterEach ->
        @removeAlertStub.restore()
      
      it "removes the alert view", ->
        @alertView.$el.find(".dismiss-alert-link").click()
        expect(@removeAlertStub).toHaveBeenCalled()
