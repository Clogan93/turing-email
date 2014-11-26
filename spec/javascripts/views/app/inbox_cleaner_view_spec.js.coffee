describe "InboxCleanerView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @inboxCleanerView = new TuringEmailApp.Views.App.InboxCleanerView(app: TuringEmailApp)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@inboxCleanerView.template).toEqual JST["backbone/templates/app/inbox_cleaner"]
