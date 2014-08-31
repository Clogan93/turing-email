describe "User model", ->
  beforeEach ->
    @user = new TuringEmailApp.Models.User()

  describe "when instantiated using fetch with data from the real server", ->
    beforeEach ->
      #fixture.preload("user.fixture.json");
      @fixtures = fixture.load("user.fixture.json", true);

      @validUser = @fixtures[0]["User"]["valid"]
      console.log @validUser
      console.log @validUser["status"]

      #@server = sinon.fakeServer.create()
      #@server.respondWith "GET", "/api/v1/users/current", @validResponse(@fixture)
      return

    afterEach ->
      #@server.restore()

    it "should make the correct request", ->
      console.log "Hello world number 2"

    # it "should make the correct request", ->
    #     @user.fetch()
    #     expect(@server.requests.length).toEqual 1
    #     expect(@server.requests[0].method).toEqual "GET"
    #     expect(@server.requests[0].url).toEqual "/api/v1/users/current"
    #     return

    # it "should parse the user from the response", ->
    #     @user.fetch()
    #     @server.respond()
    #     expect(@user.length).toEqual @fixture.response.user.length
    #     expect(@user.get(1).get("email")).toEqual @fixture.response.user[0].email
    #     return
