describe "DraftsCollection", ->

  beforeEach ->
    @draftsCollection = new TuringEmailApp.Collections.DraftsCollection()

  it "should exist", ->
    expect(TuringEmailApp.Collections.DraftsCollection).toBeDefined()

  it "should use the EmailFolder model", ->
      expect(@draftsCollection.model).toEqual TuringEmailApp.Models.EmailDraft

  it "should have the right url", ->
    expect(@draftsCollection.url).toEqual '/api/v1/email_accounts/get_draft_ids.json'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("drafts_collection.fixture.json", true);

      @validDraftsCollection = @fixtures[0]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", '/api/v1/email_accounts/get_draft_ids.json', JSON.stringify(@validDraftsCollection)

      @draftsCollection.fetch()
      @server.respond()

      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual '/api/v1/email_accounts/get_draft_ids.json'
      return

    it "should have the correct number of draft models", ->
      expect(@draftsCollection.models.length).toEqual @validDraftsCollection.length
      return
