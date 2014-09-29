class TuringEmailApp.Routers.SearchResultsRouter extends Backbone.Router
  routes:
    "search/:query": "showSearchResults"

  showSearchResults: (query) ->
    TuringEmailApp.collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsSearchResultsCollection()

    TuringEmailApp.views.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView(
      app: TuringEmailApp
      el: $("#email_table_body")
      collection: TuringEmailApp.collections.emailThreads
    )

    TuringEmailApp.collections.emailThreads.search(query)
