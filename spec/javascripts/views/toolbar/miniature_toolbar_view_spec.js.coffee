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

      it "renders as a DIV", ->
        expect(@miniatureToolbarView.el.nodeName).toEqual "DIV"

      it "sets up the settings button", ->
        spy = sinon.spy(@miniatureToolbarView, "setupSettingsButton")
        @miniatureToolbarView.render()
        expect(spy).toHaveBeenCalled()
