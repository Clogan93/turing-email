describe "UserSettings", ->
  beforeEach ->
    @userSettings = new TuringEmailApp.Models.UserSettings()
    
  it "has the right url", ->
    expect(@userSettings.url).toEqual("/api/v1/user_configurations")
