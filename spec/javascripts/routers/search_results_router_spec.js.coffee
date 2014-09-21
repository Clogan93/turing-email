describe "SearchResultsRouter", ->

  beforeEach ->
    @router = new TuringEmailApp.Routers.SearchResultsRouter()
    @routeSpy = sinon.spy()
    try
      TuringEmailApp.start()

  it "has a search#:query route and points to the showSearchResultsRouter method", ->
    expect(@router.routes["search#:query"]).toEqual "showSearchResultsRouter"
