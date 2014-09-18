class TuringEmailApp.Collections.DraftsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.Draft
  url: '/api/v1/email_accounts/get_draft_ids.json'

  parse: (response, options) ->
  	parsedResponse = []
  	for uid, draftID of response
  		draftData = {}
  		draftData[uid] = draftID
  		parsedResponse.push(draftData)
  	return parsedResponse

  updateDraft: (shouldSend=false) ->
    postData = {}
    postData.tos = $("#compose_form").find("#to_input").val().split(",")
    postData.ccs = $("#compose_form").find("#cc_input").val().split(",")
    postData.bccs = $("#compose_form").find("#bcc_input").val().split(",")
    postData.subject = $("#compose_form").find("#subject_input").val()
    postData.email_body = $("#compose_form").find("#compose_email_body").val()
    postData.email_in_reply_to_uid_input = $("#compose_form #email_in_reply_to_uid_input").val()
    if TuringEmailApp.currentEmailThread? and TuringEmailApp.currentEmailThread.get("uid")? and TuringEmailApp.emailThreads? and TuringEmailApp.emailThreads.drafts? and TuringEmailApp.emailThreads.drafts.models? and TuringEmailApp.emailThreads.drafts.models[0].attributes?
      drafts = TuringEmailApp.emailThreads.drafts.models[0].attributes
      postData.draft_id = drafts[TuringEmailApp.currentEmailThread.get("uid")]
      postUrl = 'api/v1/email_accounts/update_draft.json'
    else 
      postUrl = 'api/v1/email_accounts/create_draft.json'
    $.ajax({
      url: postUrl
      type: 'POST'
      data: postData
      dataType : 'json'
      }).done((data, status) =>
        if shouldSend
          @sendDraft postData.draft_id
        console.log status
        console.log data
      ).fail (data, status) ->
        console.log status
        console.log data

  sendDraft: (draft_id) ->
    postData = {}
    postData.draft_id = draft_id
    $.ajax({
      url: 'api/v1/email_accounts/send_draft.json'
      type: 'POST'
      data: postData
      dataType : 'json'
      }).done((data, status) ->
        console.log status
        console.log data
      ).fail (data, status) ->
        console.log status
        console.log data

    @clearComposeModal()
    $("#composeModal").modal "hide"
