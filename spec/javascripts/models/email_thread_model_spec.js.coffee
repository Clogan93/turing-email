describe "EmailThread model", ->

	beforeEach ->

	    @email_thread = new TuringEmailApp.Models.EmailThread()
	    collection = url: "/api/v1/email_threads"
	    @email_thread.collection = collection

	describe "should always support basic Backbone model functionality such as", ->

	    describe "when instantiated", ->

	        it "should exhibit attributes", ->

	            email_thread = new TuringEmailApp.Models.EmailThread(title: "Rake leaves")
	            expect(email_thread.get("title")).toEqual "Rake leaves"

	describe "urls", ->

	    describe "when no id is set", ->

	        it "should return the collection URL", ->
	            expect(@email_thread.url()).toEqual "/api/v1/email_threads"
