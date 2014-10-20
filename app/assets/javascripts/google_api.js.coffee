window.google_execute_request = (request, opt_onFulfilled, opt_onRejected, opt_context, retry) ->
  request.then(
    opt_onFulfilled
  
    (reason) ->
      if reason.status == 401 and retry?
        retry()
      else
        if opt_onRejected? then opt_onRejected(reason) else throw reason

    this
  )
