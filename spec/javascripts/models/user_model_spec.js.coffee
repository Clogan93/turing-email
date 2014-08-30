describe "User model", ->

    describe "when instantiated using fetch with data from the real server", ->

        it "should exhibit an email attribute", ->

            todo = new TuringEmailApp.Models.User(title: "Rake leaves")
            expect(todo.get("title")).toEqual "Rake leaves"
            