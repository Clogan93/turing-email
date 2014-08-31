describe "User model", ->
  beforeEach ->
    @user = new TuringEmailApp.Models.User()

  it "should exist", ->
    expect(TuringEmailApp.Models.User).toBeDefined()

  it "should have the right url", ->
    expect(@user.url).toEqual '/api/v1/users/current'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("user.fixture.json", true);

      @validUser = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/users/current", JSON.stringify(@validUser)
      return

    afterEach ->
      @server.restore()

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

  describe "Validations", ->

    attrs = {}
 
    beforeEach ->
      attrs =
        email: 'test44@gmail.com'
 
    afterEach ->
      newUser = new TuringEmailApp.Models.User attrs
      expect(newUser.isValid()).toBeFalsy()
 
    it "should validate the presence of email", ->
      attrs["email"] = null
