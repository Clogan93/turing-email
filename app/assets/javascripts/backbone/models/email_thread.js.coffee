class TuringEmailApp.Models.EmailThread extends Backbone.Model

  seenIs: (seenValue=true)->
    postData = {}
    emailUids = []
    for email in @.get("emails")
      emailUids.push email.uid
    postData.email_uids = emailUids
    postData.seen = seenValue

    url = "/api/v1/emails/set_seen.json"
    $.ajax
      type: "POST"
      url: url
      data: postData
      success: (data) ->
        return

  uid:
    required: true

  emails:
    required: true
