googleProcessError = (reason, app, makeRequest, attempt) ->
  if reason.status == 401 and app?
    app.refreshGmailAPIToken().done(=> makeRequest())
  else if reason.status == 429
    setTimeout(
      => makeRequest(attempt + 1)
      Math.pow(2, attempt) + Math.random() * 1000
    )
  else
    if opt_onRejected? then opt_onRejected(reason) else throw reason

window.googleRequest = (app, generateRequest, opt_onFulfilled, opt_onRejected, opt_context) ->
  if app? and not app.gmailAPIReady
    setTimeout(
      => googleRequest(app, generateRequest, opt_onFulfilled, opt_onRejected, opt_context)
      100
    )

    return
    
  makeRequest = (attempt=0) =>
    request = generateRequest()

    request.then(
      opt_onFulfilled
      (reason) -> googleProcessError(reason, app, makeRequest, attempt)
      opt_context
    )

  makeRequest()