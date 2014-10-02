describe "User", ->
  beforeEach ->
    userFixtures = fixture.load("user.fixture.json");
    @validUserFixture = userFixtures[0]["valid"]

    @user = new TuringEmailApp.Models.User()

    @server = sinon.fakeServer.create()

    @url = "/api/v1/users/current"
    @server.respondWith "GET", @url, JSON.stringify(@validUserFixture)

  afterEach ->
    @server.restore()
    
  it "has the right url", ->
    expect(@user.url).toEqual @url

  describe "#fetch", ->
    beforeEach ->
      @user.fetch()
      @server.respond()

    it "loads the user", ->
      validateUserAttributes(@user.toJSON())
