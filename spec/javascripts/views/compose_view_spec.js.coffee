describe "ComposeView", ->

  beforeEach ->
    @composeView = new TuringEmailApp.Views.ComposeView()

  it "should be defined", ->
    expect(TuringEmailApp.Views.ComposeView).toBeDefined()

  it "loads the list item template", ->
    expect(@composeView.template).toEqual JST["backbone/templates/compose"]
