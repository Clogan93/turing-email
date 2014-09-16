class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email_thread#:uid": "showEmailThread"
    "email_draft#:uid": "showEmailDraft"

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

  showEmailDraft: (emailThreadUID) ->
    TuringEmailApp.currentEmailThread = TuringEmailApp.emailThreads.getEmailThread(emailThreadUID)

    if TuringEmailApp.currentEmailThread?
      TuringEmailApp.emailThreadsListView.prepareComposeModalWithEmailThreadData TuringEmailApp.currentEmailThread.get("emails")[0], ""
    else
      TuringEmailApp.currentEmailThread = new TuringEmailApp.Models.EmailThread()
      TuringEmailApp.currentEmailThread.url = "/api/v1/email_threads/show/" + emailThreadUID
      
      TuringEmailApp.currentEmailThread.fetch(
        success: (model, response, options) =>
          console.log model
          TuringEmailApp.emailThreadsListView.prepareComposeModalWithEmailThreadData model.get("emails")[0], ""
      )
