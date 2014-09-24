describe "EmailThreadsSearchResultsCollection", ->
  beforeEach ->
    emailThreadSearchResultsFixtures = fixture.load("email_thread_search_results.fixture.json");
    @validEmailThreadSearchResultsFixture = emailThreadSearchResultsFixtures[0]["valid"]
    
    @url = "/api/v1/email_accounts/search_threads"
    @emailThreadSearchResultsCollection = new TuringEmailApp.Collections.EmailThreadsSearchResultsCollection()
    
    @server = sinon.fakeServer.create()
    @server.respondWith "POST", @url, JSON.stringify(@validEmailThreadSearchResultsFixture)

    @emailThreadSearchResultsCollection.search("test")
    @server.respond()
    
  afterEach ->
    @server.restore()

  it "should use the EmailThread model", ->
    expect(@emailThreadSearchResultsCollection.model).toEqual TuringEmailApp.Models.EmailThread
  
  it "should have the right url", ->
    expect(@emailThreadSearchResultsCollection.url).toEqual @url

  describe "#fetch", ->
    it "loads the search results", ->
      expect(@emailThreadSearchResultsCollection.nextPageToken).toEqual @validEmailThreadSearchResultsFixture["next_page_token"]
      expect(@emailThreadSearchResultsCollection.length).toEqual @validEmailThreadSearchResultsFixture["email_threads"].length
      expect(@emailThreadSearchResultsCollection.toJSON()).toEqual @validEmailThreadSearchResultsFixture["email_threads"]
  
      for emailThread in @emailThreadSearchResultsCollection.models
        validateEmailThreadAttributes(emailThread.toJSON())
  
        for email in emailThread.get("emails")
          validateEmailAttributes(email)
