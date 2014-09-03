class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email_thread#:uid": "showEmailThread"

  showEmailThread: (emailThreadUID) ->
    emailThread = TuringEmailApp.emailThreads.getEmailThread(emailThreadUID)
    emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: emailThread
      el: $("#email_table_body")
    )
    emailThreadView.render()
