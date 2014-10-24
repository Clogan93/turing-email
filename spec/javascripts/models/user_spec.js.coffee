describe "User", ->
  beforeEach ->
    @user = new TuringEmailApp.Models.User()

  it "has the right url", ->
    expect(@user.url).toEqual("/api/v1/users/current")
