class TuringEmailApp.Routers.SearchResultsRouter extends Backbone.Router
  routes:
    "search/:query": "showSearchResults"

  showSearchResults: (query) ->
    TuringEmailApp.loadSearchResults(query)
