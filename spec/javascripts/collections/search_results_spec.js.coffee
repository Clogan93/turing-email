describe "EmailThreadsSearchResultsCollection", ->
  beforeEach ->
    @emailThreadsSearchResults = new TuringEmailApp.Collections.EmailThreadsSearchResultsCollection(undefined, app: TuringEmailApp)
    
  it "should use the EmailThread model", ->
    expect(@emailThreadsSearchResults.model).toEqual TuringEmailApp.Models.EmailThread
    
  it "has the right URL", ->
    expect(TuringEmailApp.Collections.EmailThreadsSearchResultsCollection.SEARCH_URL).toEqual("/api/v1/email_accounts/search_threads")
  
  describe "#search", ->
    beforeEach ->
      [@server, @validEmailThreadSearchResultsFixture] = specPrepareSearchResultsFetch()
  
      @emailThreadsSearchResults.search(query: "test")
      @server.respond()

    afterEach ->
      @server.restore()
    
    it "loads the search results", ->
      expect(@emailThreadsSearchResults.nextPageToken).toEqual @validEmailThreadSearchResultsFixture["next_page_token"]
      expect(@emailThreadsSearchResults.length).toEqual @validEmailThreadSearchResultsFixture["email_threads"].length
      expect(@emailThreadsSearchResults.toJSON()).toEqual @validEmailThreadSearchResultsFixture["email_threads"]
  
      for emailThread in @emailThreadsSearchResults.models
        validateEmailThreadAttributes(emailThread.toJSON())
  
        for email in emailThread.get("emails")
          validateEmailAttributes(email)
