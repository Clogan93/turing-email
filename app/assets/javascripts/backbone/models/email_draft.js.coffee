class TuringEmailApp.Models.EmailDraft extends TuringEmailApp.Models.Email
  url: "/api/v1/email_accounts/drafts"

  @sendDraftRequest: (draftID) ->
    gapi.client.gmail.users.drafts.send({userId: "me"}, {id: draftID})
  
  @sendDraft: (app, draftID, success, error) ->
    googleRequest(
      app
      => TuringEmailApp.Models.EmailDraft.sendDraftRequest(draftID)
    )

  sendDraft: (app, success, error) ->
    TuringEmailApp.Models.EmailDraft.sendDraft(app, @get("draft_id"), success, error)
