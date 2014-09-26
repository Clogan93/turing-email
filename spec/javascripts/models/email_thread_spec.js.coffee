describe "EmailThread", ->
  beforeEach ->
    emailThreadFixtures = fixture.load("email_thread.fixture.json");
    @validEmailThreadFixture = emailThreadFixtures[0]["valid"]
    
    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadUID: @validEmailThreadFixture["uid"])

    @server = sinon.fakeServer.create()

    @url = "/api/v1/email_threads/show/" + @validEmailThreadFixture["uid"]
    @server.respondWith "GET", @url, JSON.stringify(@validEmailThreadFixture)
    
  afterEach ->
    @server.restore()

  it "has the right url", ->
    expect(@emailThread.url).toEqual @url
    
  describe "#fetch", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()
      
    it "loads the email thread", ->
      validateEmailThreadAttributes(@emailThread.toJSON())
  
      for email in @emailThread.get("emails")
        validateEmailAttributes(email)

  describe "#seenIs", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()
      
      @setSeenURL = "/api/v1/emails/set_seen"
      @server.respondWith "POST", @setSeenURL, JSON.stringify({})

      @emailUIDs = (email["uid"] for email in @validEmailThreadFixture["emails"])
      @emailUIDs.sort()

    afterEach ->
      @server.restore()

    describe "seenValue=true", ->
      beforeEach ->
        @emailThread.seenIs(true)
        @server.respond()

      it "sets seen to true", ->
        expect(@server.requests.length).toEqual 2
        request = @server.requests[1]
        
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual @setSeenURL
        
        postData = $.unserialize(request.requestBody)
        expect(postData["seen"]).toEqual("true")
        expect(postData["email_uids"].sort()).toEqual(@emailUIDs)

    describe "seenValue=false", ->
      beforeEach ->
        @emailThread.seenIs(false)
        @server.respond()

      it "sets seen to false", ->
        expect(@server.requests.length).toEqual 2
        request = @server.requests[1]
        
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual @setSeenURL

        postData = $.unserialize(request.requestBody)
        expect(postData["seen"]).toEqual("false")
        expect(postData["email_uids"].sort()).toEqual(@emailUIDs)
