FactoryGirl.define "UserSettings", ->
  @sequence("id", "id");
  @demo_mode_enabled = true
  @keyboard_shortcuts_enabled = true
  @genie_enabled = true
  @split_pane_mode = "horizontal"
  @developer_enabled = false

  @installed_apps = FactoryGirl.createLists("InstalledPanelApp", FactoryGirl.SMALL_LIST_SIZE)
