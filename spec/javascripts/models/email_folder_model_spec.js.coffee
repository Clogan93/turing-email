describe "EmailFolder model", ->

  it "should exist", ->
    expect(TuringEmailApp.Models.EmailFolder).toBeDefined()

  describe "when instantiated using fetch with data from the real server", ->

    it "should exhibit attributes", ->

      todo = new TuringEmailApp.Models.EmailFolder(title: "Rake leaves")
      expect(todo.get("title")).toEqual "Rake leaves"
