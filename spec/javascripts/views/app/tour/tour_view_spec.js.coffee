describe "TourView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @tourView = new TuringEmailApp.Views.App.TourView()

  afterEach ->
    specStopTuringEmailApp()
    
  it "has the right template", ->
    expect(@tourView.template).toEqual JST["backbone/templates/app/tour/tour"]

  describe "#render", ->

    it "calls the powerTour method on the body", ->
      @powerTourStub = sinon.stub($.fn, "powerTour", ->)
      @tourView.render()
      expect(@powerTourStub).toHaveBeenCalled()
      @powerTourStub.restore()
