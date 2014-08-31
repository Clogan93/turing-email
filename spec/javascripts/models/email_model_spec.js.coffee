describe "Email model", ->

  it "should exist", ->
    expect(TuringEmailApp.Models.Email).toBeDefined()

  describe "when instantiated using fetch with data from the real server", ->

    it "should exhibit an email attributes", ->
