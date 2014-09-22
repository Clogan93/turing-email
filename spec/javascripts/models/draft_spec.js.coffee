describe "UserSettings model", ->
  beforeEach ->
    @draft = new TuringEmailApp.Models.EmailDraft()

  it "should exist", ->
    expect(TuringEmailApp.Models.EmailDraft).toBeDefined()
