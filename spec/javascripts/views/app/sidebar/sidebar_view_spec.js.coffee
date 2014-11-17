describe "SidebarView", ->
  beforeEach ->
    @sidebarView = new TuringEmailApp.Views.App.SidebarView()

  it "has the right template", ->
    expect(@sidebarView.template).toEqual JST["backbone/templates/app/sidebar/sidebar"]
