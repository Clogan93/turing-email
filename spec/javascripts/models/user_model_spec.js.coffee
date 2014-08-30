describe "User model", ->

    describe "when instantiated with fetch", ->

        it "should exhibit an email attribute", ->

            todo = new TuringEmailApp.Models.User(title: "Rake leaves")
            expect(todo.get("title")).toEqual "Rake leaves"
            