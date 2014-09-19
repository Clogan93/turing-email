describe "ToolbarView", ->

  beforeEach ->
    @toolbarView = new TuringEmailApp.Views.ToolbarView()

  it "should be defined", ->
    expect(TuringEmailApp.Views.ToolbarView).toBeDefined()

  it "loads the list item template", ->
    expect(@toolbarView.template).toEqual JST["backbone/templates/toolbar_view"]
