class TuringEmailApp.Routers.SearchResultsRouter extends Backbone.Router
  routes:
    "search#:query": "showSearchResultsRouter"

  showSearchResultsRouter: (query) ->
    TuringEmailApp.emailThreads = new TuringEmailApp.Collections.SearchResultsCollection(
      url: "/api/v1/email_accounts/search_threads"
    )

    TuringEmailApp.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView({
      el: $("#email_table_body")
      collection: TuringEmailApp.emailThreads
    })

    TuringEmailApp.emailThreads.fetch(
      data: {'query': query}
      type: 'POST'
      reset: true
      success: (collection, response, options) ->
        TuringEmailApp.emailThreads.next_page_token = response.next_page_token
    )
