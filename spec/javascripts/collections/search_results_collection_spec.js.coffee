describe "SearchResultsCollection", ->

  beforeEach ->
    @searchResultsCollection = new TuringEmailApp.Collections.SearchResultsCollection(
      url: "/api/v1/email_accounts/search_threads"
    )

  it "should exist", ->
    expect(TuringEmailApp.Collections.SearchResultsCollection).toBeDefined()

  it "should have the right url", ->
    expect(@searchResultsCollection.url).toEqual "/api/v1/email_accounts/search_threads"
