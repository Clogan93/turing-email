describe "EmbeddedComposeView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @embeddedComposeView = new TuringEmailApp.Views.App.EmbeddedComposeView(app: TuringEmailApp)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@embeddedComposeView.template).toEqual JST["backbone/templates/app/compose/embedded_compose_view"]
