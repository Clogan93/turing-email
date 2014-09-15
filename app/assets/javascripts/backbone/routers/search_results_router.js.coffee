class TuringEmailApp.Routers.SearchResultsRouter extends Backbone.Router
  routes:
    "search#:query": "showSearchResultsRouter"
    
  showEmailThread: (emailThreadUID) ->
  showSearchResultsRouter: (query) ->
    TuringEmailApp.emailThreads = new TuringEmailApp.Collections.SearchResultsCollection(
      url: "/api/v1/email_accounts/search_threads"
    )

    TuringEmailApp.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView({
      el: $("#email_table_body")
      collection: TuringEmailApp.emailThreads
    })

    TuringEmailApp.emailThreads.fetch(
      reset: true
    )
