class TuringEmailApp.Collections.SearchResultsCollection extends TuringEmailApp.Collections.EmailThreadsCollection

  initialize: (options) ->
    @url = options.url

  parse: (response, options) ->
    return response.email_threads
