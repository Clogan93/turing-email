class TuringEmailApp.Routers.SearchResultsRouter extends Backbone.Router
  routes:
    "search#:query": "showSearchResultsRouter"

  showSearchResultsRouter: (query) ->
    TuringEmailApp.collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsSearchResultsCollection()

    TuringEmailApp.views.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView({
      el: $("#email_table_body")
      collection: TuringEmailApp.collections.emailThreads
    })

    TuringEmailApp.collections.emailThreads.fetch(
      data: {'query': query}
      type: 'POST'
      reset: true
    )
