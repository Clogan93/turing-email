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

    it "should make the correct request", ->
      console.log "Hello world number 2"

    afterEach ->
      #@server.restore()
      return
