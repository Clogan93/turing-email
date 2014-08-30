describe "Email model", ->

	describe "supports basic Backbone model functionality", ->

	    describe "when instantiated", ->

	        it "should exhibit attributes", ->

	            todo = new TuringEmailApp.Models.Email(title: "Rake leaves")
	            expect(todo.get("title")).toEqual "Rake leaves"
	            return

	        return

	    return

    return
