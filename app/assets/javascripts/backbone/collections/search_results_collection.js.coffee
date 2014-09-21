class TuringEmailApp.Collections.EmailThreadsSearchResultsCollection extends TuringEmailApp.Collections.EmailThreadsCollection
  url: "/api/v1/email_accounts/search_threads"

  parse: (response, options) ->
    # not sure this is the right thing to do. Maybe there should be a EmailSearchResultsModel
    # that has two attributes - nextPageToken and emailThreads collection. 
    @nextPageToken = response.next_page_token
    return response.email_threads
