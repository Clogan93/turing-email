class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email_thread#:uid": "showEmailThread"
    "email_draft#:uid": "showEmailDraft"

  showEmailThread: (emailThreadUID) ->
    emailThread = TuringEmailApp.collections.emailThreads.getEmailThread(emailThreadUID)
    
    if emailThread?
      TuringEmailApp.currentEmailThreadIs emailThread
    else
      emailThread = new TuringEmailApp.Models.EmailThread(url: "/api/v1/email_threads/show/" + emailThreadUID)
      emailThread.fetch(
        success: (model, response, options) =>
          TuringEmailApp.currentEmailThreadIs emailThread
      )

  showEmailDraft: (emailThreadUID) ->
    TuringEmailApp.currentEmailThreadIs TuringEmailApp.collections.emailThreads.getEmailThread(emailThreadUID)

    if TuringEmailApp.currentEmailThread?
      TuringEmailApp.views.composeView.loadEmailDraft TuringEmailApp.currentEmailThread.get("emails")[0]
      TuringEmailApp.views.composeView.show()
    else
      newEmailThread = new TuringEmailApp.Models.EmailThread()
      TuringEmailApp.currentEmailThreadIs newEmailThread
      TuringEmailApp.currentEmailThread.url = "/api/v1/email_threads/show/" + emailThreadUID
      
      TuringEmailApp.currentEmailThread.fetch(
        success: (model, response, options) =>
          TuringEmailApp.views.composeView.loadEmailDraft model.get("emails")[0]
          TuringEmailApp.views.composeView.show()
      )
