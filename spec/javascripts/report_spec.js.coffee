describe "Report", ->
  beforeEach ->
    @linksDiv = $("<div><div class='collapse-link'></div><div class='close-link'></div></div>").appendTo("body")
    @view = new Backbone.View(
      el: @linksDiv
    )
    @report = new Report(@view)

  afterEach ->
    @linksDiv.remove()

  describe "#constructor", ->

    it "should take a view object in the constructor", ->
      expect(@report.view).toEqual @view

  describe "#setupContainers", ->
    beforeEach ->
      @report.setupContainers()

    it "binds the click event to the collapse link", ->
      expect(@view.$el.find(".collapse-link")).toHandle("click")

    it "binds the click event to the close link", ->
      expect(@view.$el.find(".close-link")).toHandle("click")
