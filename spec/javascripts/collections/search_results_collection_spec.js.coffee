describe "EmailThreadsSearchResultsCollection", ->
  beforeEach ->
    @url = "/api/v1/email_accounts/search_threads"
    @emailThreadSearchResultsCollection = new TuringEmailApp.Collections.EmailThreadsSearchResultsCollection()

    emailThreadSearchResults = fixture.load("email_thread_search_results.fixture.json");
    @validEmailThreadSearchResults = emailThreadSearchResults[0]["valid"]
    
    @server = sinon.fakeServer.create()
    @server.respondWith "POST", @url, JSON.stringify(@validEmailThreadSearchResults)

    @emailThreadSearchResultsCollection.fetch(
      data: {'query': "test"}
      type: 'POST'
      reset: true
    )
    @server.respond()
    
  afterEach ->
    @server.restore()

  it "should use the EmailThread model", ->
    expect(@emailThreadSearchResultsCollection.model).toEqual TuringEmailApp.Models.EmailThread
  
  it "should have the right url", ->
    expect(@emailThreadSearchResultsCollection.url).toEqual @url

  describe "#fetch", ->
    it "loads the search results", ->
      expect(@emailThreadSearchResultsCollection.nextPageToken).toEqual @validEmailThreadSearchResults["next_page_token"]
      expect(@emailThreadSearchResultsCollection.length).toEqual @validEmailThreadSearchResults["email_threads"].length
      expect(@emailThreadSearchResultsCollection.toJSON()).toEqual @validEmailThreadSearchResults["email_threads"]
  
      for emailThread in @emailThreadSearchResultsCollection.models
        validateEmailThreadAttributes(emailThread.toJSON())
  
        for email in emailThread.get("emails")
          validateEmailAttributes(email)
