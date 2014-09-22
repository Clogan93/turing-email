class TuringEmailApp.Routers.SearchResultsRouter extends Backbone.Router
  routes:
    "search#:query": "showSearchResultsRouter"

  showSearchResultsRouter: (query) ->
    TuringEmailApp.emailThreads = new TuringEmailApp.Collections.EmailThreadsSearchResultsCollection()

    TuringEmailApp.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView({
      el: $("#email_table_body")
      collection: TuringEmailApp.emailThreads
    })

    TuringEmailApp.emailThreads.fetch(
      data: {'query': query}
      type: 'POST'
      reset: true
    )
