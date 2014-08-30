describe "EmailThreads collection", ->
    beforeEach ->
        @email_thread1 = new Backbone.Model(
            id: 1
            title: "EmailThread 1"
        )
        @email_thread2 = new Backbone.Model(
            id: 2
            title: "EmailThread 2"
        )
        @email_thread3 = new Backbone.Model(
            id: 3
            title: "EmailThread 3"
        )
        @email_thread4 = new Backbone.Model(
            id: 4
            title: "EmailThread 4"
        )
        @email_threads = new TuringEmailApp.Collections.EmailThreadsCollection()
        @email_thread_stub = sinon.stub(window, "EmailThread")

    afterEach ->
        @email_thread_stub.restore()
