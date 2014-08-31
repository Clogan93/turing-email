#= require sinon

describe "User model", ->

    beforeEach ->
        @user = new TuringEmailApp.Models.User()

    describe "when instantiated using fetch with data from the real server", ->

        beforeEach ->
            console.log @fixtures
            @fixture = @fixtures.User.valid
            @fixtureEmail = @fixture.response.email
            @server = sinon.fakeServer.create()
            @server.respondWith "GET", "/api/v1/users/current", @validResponse(@fixture)
            return

        it "should make the correct request", ->
            console.log "Hello world number 2"

        afterEach ->
            @server.restore()
            return
