describe "SearchResultsRouter", ->
  beforeEach ->
    specStartTuringEmailApp()
    
    @searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  it "has the expected routes", ->
    expect(@searchResultsRouter.routes["search/:query"]).toEqual "showSearchResults"

  describe "search/:query", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp.Views.EmailThreads, "ListView")
      @searchResultsRouter.navigate "search/test", trigger: true

    afterEach ->
      @spy.restore()

    it "shows a ListView", ->
      expect(@spy).toHaveBeenCalled()
