describe "UserConfiguration", ->
  beforeEach ->
    @userConfiguration = new TuringEmailApp.Models.UserConfiguration()
    
  it "has the right url", ->
    expect(@userConfiguration.url).toEqual("/api/v1/user_configurations")
