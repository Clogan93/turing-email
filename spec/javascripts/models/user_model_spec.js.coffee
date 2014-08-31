describe "User model", ->

  it "should exist", ->
    expect(TuringEmailApp.Models.User).toBeDefined()

  beforeEach ->
    @user = new TuringEmailApp.Models.User()

  describe "when instantiated using fetch with data from the real server", ->

    beforeEach ->
      @fixtures = fixture.load("user.fixture.json", true);

      @validUser = @fixtures[0]["User"]["valid"]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/users/current", JSON.stringify(@validUser)
      return

    it "should make the correct request", ->
        @user.fetch()
        expect(@server.requests.length).toEqual 1
        expect(@server.requests[0].method).toEqual "GET"
        expect(@server.requests[0].url).toEqual "/api/v1/users/current"
        return

    it "should parse the email from the response", ->
        @user.fetch()
        @server.respond()
        expect(@user.get("email")).toEqual @validUser.email
        return

    it "should have the email attribute", ->
      @user.fetch()
      @server.respond()
      expect(@user.get("email")).toBeDefined()

    afterEach ->
      @server.restore()
