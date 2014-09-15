class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email_thread#:uid": "showEmailThread"

  showEmailThread: (emailThreadUID) ->
    TuringEmailApp.currentEmailThread = TuringEmailApp.emailThreads.getEmailThread(emailThreadUID)
    
    if TuringEmailApp.currentEmailThread?
      @renderEmailThread TuringEmailApp.currentEmailThread
    else
      TuringEmailApp.currentEmailThread = new TuringEmailApp.Models.EmailThread()
      TuringEmailApp.currentEmailThread.url = "/api/v1/email_threads/show/" + emailThreadUID
      
      TuringEmailApp.currentEmailThread.fetch(
        success: (model, response, options) =>
          @renderEmailThread model
      )

  renderEmailThread: (emailThread) ->
    emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: emailThread
      el: $("#email_table_body")
    )
    
    emailThreadView.render()
