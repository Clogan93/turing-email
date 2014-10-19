class TuringEmailApp.Collections.EmailThreadsSearchResultsCollection extends TuringEmailApp.Collections.EmailThreadsCollection
  @SEARCH_URL = "/api/v1/email_accounts/search_threads"

  parse: (response, options) ->
    # not sure this is the right thing to do. Maybe there should be a EmailSearchResultsModel
    # that has two attributes - nextPageToken and emailThreads collection.
    
    if response.email_threads?
      @nextPageToken = response.next_page_token
      return response.email_threads
    else
      return super(response, options)
    
  search: (options) ->
    @fetch(
      url: TuringEmailApp.Collections.EmailThreadsSearchResultsCollection.SEARCH_URL
      data: {'query': options.query}
      type: 'POST'
      reset: options.reset
      success: options.success
      error: options.error
    )
