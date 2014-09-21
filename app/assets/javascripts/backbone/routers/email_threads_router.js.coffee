class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email_thread#:uid": "showEmailThread"
    "email_draft#:uid": "showEmailDraft"

  showEmailThread: (emailThreadUID) ->
    if TuringEmailApp.userSettings.get("split_pane_mode") is "horizontal"
      $("#preview_panel").show()
      TuringEmailApp.currentEmailThread = TuringEmailApp.emailThreads.getEmailThread(emailThreadUID)

      TuringEmailApp.previewEmailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
        model: TuringEmailApp.currentEmailThread
        el: $("#preview_content")
      )
      TuringEmailApp.previewEmailThreadView.render()
    else
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
    $("#email-folder-mail-header").hide()
    emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: emailThread
      el: $("#email_table_body")
    )
    
    emailThreadView.render()

  showEmailDraft: (emailThreadUID) ->
    TuringEmailApp.currentEmailThread = TuringEmailApp.emailThreads.getEmailThread(emailThreadUID)

    if TuringEmailApp.currentEmailThread?
      TuringEmailApp.composeView.loadEmailDraft TuringEmailApp.currentEmailThread.get("emails")[0]
    else
      TuringEmailApp.currentEmailThread = new TuringEmailApp.Models.EmailThread()
      TuringEmailApp.currentEmailThread.url = "/api/v1/email_threads/show/" + emailThreadUID
      
      TuringEmailApp.currentEmailThread.fetch(
        success: (model, response, options) =>
          TuringEmailApp.composeView.loadEmailDraft model.get("emails")[0]
      )
