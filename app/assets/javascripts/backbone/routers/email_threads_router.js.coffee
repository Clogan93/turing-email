class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email_thread#:uid": "showEmailThread"

  showEmailThread: (emailThreadUID) ->
    emailThread = TuringEmailApp.emailThreads.getEmailThread(emailThreadUID)
    if emailThread?
      @renderEmailThread emailThread
    else
      emailThread = new TuringEmailApp.Models.EmailThread()
      emailThread.url = "/api/v1/email_threads/show/" + emailThreadUID
      emailThread.fetch(
        success: (model, response, options) =>
          @renderEmailThread model
      )

  renderEmailThread: (emailThread) ->
    emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: emailThread
      el: $("#email_table_body")
    )
    emailThreadView.render()
