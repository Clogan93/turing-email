class TuringEmailApp.Models.EmailDraft extends TuringEmailApp.Models.Email
  url: "/api/v1/email_accounts/drafts"

  sendDraft: ->
    postData = {}
    postData.draft_id = @get("draft_id")
    
    $.ajax({
      url: "/api/v1/email_accounts/send_draft"
      type: "POST"
      data: postData
      dataType : "json"
    })
