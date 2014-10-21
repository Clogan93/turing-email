window.google_execute_request = (request, opt_onFulfilled, opt_onRejected, opt_context, retry, attempt=0) ->
  request.then(
    opt_onFulfilled
  
    (reason) ->
      if reason.status == 401 and retry?
        retry()
      else if reason.status == 429 and retry?
        setTimeout(
          => retry()
          Math.pow(2, attempt) + Math.random() * 1000
        )
      else
        if opt_onRejected? then opt_onRejected(reason) else throw reason

    this
  )
