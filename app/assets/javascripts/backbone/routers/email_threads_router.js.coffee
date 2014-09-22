class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email_thread#:uid": "showEmailThread"
    "email_draft#:uid": "showEmailDraft"

  showEmailThread: (emailThreadUID) ->
    TuringEmailApp.views.emailThreadsListView.currentEmailThread = TuringEmailApp.collections.emailThreads.getEmailThread(emailThreadUID)
    
    if TuringEmailApp.models.userSettings.get("split_pane_mode") is "horizontal"
      $("#preview_panel").show()

      TuringEmailApp.views.previewEmailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
        model: TuringEmailApp.views.emailThreadsListView.currentEmailThread
        el: $("#preview_content")
      )
      TuringEmailApp.views.previewEmailThreadView.render()
    else
      if TuringEmailApp.views.emailThreadsListView.currentEmailThread?
        @renderEmailThread TuringEmailApp.views.emailThreadsListView.currentEmailThread
      else
        TuringEmailApp.views.emailThreadsListView.currentEmailThread = new TuringEmailApp.Models.EmailThread()
        TuringEmailApp.views.emailThreadsListView.currentEmailThread.url = "/api/v1/email_threads/show/" + emailThreadUID
        
        TuringEmailApp.views.emailThreadsListView.currentEmailThread.fetch(
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
    TuringEmailApp.views.emailThreadsListView.currentEmailThread = TuringEmailApp.collections.emailThreads.getEmailThread(emailThreadUID)

    if TuringEmailApp.views.emailThreadsListView.currentEmailThread?
      TuringEmailApp.views.composeView.loadEmailDraft TuringEmailApp.views.emailThreadsListView.currentEmailThread.get("emails")[0]
      TuringEmailApp.views.composeView.show()
    else
      TuringEmailApp.views.emailThreadsListView.currentEmailThread = new TuringEmailApp.Models.EmailThread()
      TuringEmailApp.views.emailThreadsListView.currentEmailThread.url = "/api/v1/email_threads/show/" + emailThreadUID
      
      TuringEmailApp.views.emailThreadsListView.currentEmailThread.fetch(
        success: (model, response, options) =>
          TuringEmailApp.views.composeView.loadEmailDraft model.get("emails")[0]
          TuringEmailApp.views.composeView.show()
      )
