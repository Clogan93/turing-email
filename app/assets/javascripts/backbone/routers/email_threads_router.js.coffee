class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email_thread#:uid": "showEmailThread"
    "email_draft#:uid": "showEmailDraft"

  showEmailThread: (emailThreadUID) ->
    TuringEmailApp.currentEmailThreadIs(emailThreadUID)

  showEmailDraft: (emailThreadUID) ->
    TuringEmailApp.showEmailEditorWithEmailThread(emailThreadUID)

