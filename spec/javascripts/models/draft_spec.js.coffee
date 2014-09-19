describe "UserSettings model", ->
  beforeEach ->
    @draft = new TuringEmailApp.Models.Draft()

  it "should exist", ->
    expect(TuringEmailApp.Models.Draft).toBeDefined()
