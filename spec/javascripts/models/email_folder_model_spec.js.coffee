describe "EmailFolder model", ->

    describe "when instantiated", ->

        it "should exhibit attributes", ->

            todo = new TuringEmailApp.Models.EmailFolder(title: "Rake leaves")
            expect(todo.get("title")).toEqual "Rake leaves"
