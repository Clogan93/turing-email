describe "MiniatureToolbarView", ->
  beforeEach ->
    specStartTuringEmailApp()
    
    @miniatureToolbarView = new TuringEmailApp.Views.MiniatureToolbarView(
      app: TuringEmailApp
    )
    
  afterEach ->
    specStopTuringEmailApp()

  describe "after render", ->
    beforeEach ->
      @miniatureToolbarView.render()

    describe "#render", ->
      beforeEach ->
        @setupSettingsButtonStub = sinon.stub(@miniatureToolbarView, "setupSettingsButton")
        
      afterEach ->
        @setupSettingsButtonStub.restore()
      
      it "renders as a DIV", ->
        expect(@miniatureToolbarView.el.nodeName).toEqual "DIV"

      it "sets up the settings button", ->
        @miniatureToolbarView.render()
        expect(@setupSettingsButtonStub).toHaveBeenCalled()
