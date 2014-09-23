class TuringEmailApp.Models.EmailDraft extends TuringEmailApp.Models.Email
  url: "/api/v1/email_accounts/drafts"

  sendDraft: (draft_id) ->
    postData = {}
    postData.draft_id = @get("draft_id")
    $.ajax({
      url: '/api/v1/email_accounts/send_draft.json'
      type: 'POST'
      data: postData
      dataType : 'json'
    }).done((data, status) ->
      return
    ).fail (data, status) ->
      TuringEmailApp.tattletale.log(JSON.stringify(status))
      TuringEmailApp.tattletale.log(JSON.stringify(data))
      TuringEmailApp.tattletale.send()

    TuringEmailApp.views.composeView.resetView()
    $("#composeModal").modal "hide"
