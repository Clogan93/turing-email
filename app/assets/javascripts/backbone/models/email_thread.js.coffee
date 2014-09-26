class TuringEmailApp.Models.EmailThread extends Backbone.Model
  validation:
    uid:
      required: true

    emails:
      required: true

  initialize: (attributes) ->
    if attributes?.emailThreadUID
      @url = "/api/v1/email_threads/show/" + attributes.emailThreadUID
      @unset("emailThreadUID")

  seenIs: (seenValue=true)->
    postData = {}
    emailUIDs = []

    for email in @get("emails")
      emailUIDs.push email.uid
    
    postData.email_uids = emailUIDs
    postData.seen = seenValue

    url = "/api/v1/emails/set_seen"
    $.ajax
      type: "POST"
      url: url
      data: postData
      dataType : "json"
