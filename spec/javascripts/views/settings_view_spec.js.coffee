describe "SettingsView", ->

  beforeEach ->
    @settingsView = new TuringEmailApp.Views.SettingsView()

  it "should be defined", ->
    expect(TuringEmailApp.Views.SettingsView).toBeDefined()

  it "loads the list item template", ->
    expect(@settingsView.template).toEqual JST["backbone/templates/settings"]
