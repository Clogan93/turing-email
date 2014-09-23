class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email_thread#:uid": "showEmailThread"
    "email_draft#:uid": "showEmailDraft"

  showEmailThread: (emailThreadUID) ->
    TuringEmailApp.currentEmailThreadIs TuringEmailApp.collections.emailThreads.getEmailThread(emailThreadUID)
    
    if TuringEmailApp.models.userSettings.get("split_pane_mode") is "horizontal"
      $("#preview_panel").show()

      TuringEmailApp.views.previewEmailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
        model: TuringEmailApp.currentEmailThread
        el: $("#preview_content")
      )
      TuringEmailApp.views.previewEmailThreadView.render()
    else
      if TuringEmailApp.currentEmailThread?
        @renderEmailThread TuringEmailApp.currentEmailThread
      else
        newEmailThread = new TuringEmailApp.Models.EmailThread()
        TuringEmailApp.currentEmailThreadIs newEmailThread
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
