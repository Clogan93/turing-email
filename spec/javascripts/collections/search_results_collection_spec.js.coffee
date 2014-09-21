describe "EmailThreadsSearchResultsCollection", ->

  beforeEach ->
    @searchResultsCollection = new TuringEmailApp.Collections.EmailThreadsSearchResultsCollection(
      url: "/api/v1/email_accounts/search_threads"
    )

  it "should exist", ->
    expect(TuringEmailApp.Collections.EmailThreadsSearchResultsCollection).toBeDefined()

  it "should have the right url", ->
    expect(@searchResultsCollection.url).toEqual "/api/v1/email_accounts/search_threads"
