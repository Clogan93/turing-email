class TuringEmailApp.Collections.EmailDraftIDsCollection extends Backbone.Collection
  url: '/api/v1/email_accounts/get_draft_ids.json'

  parse: (response, options) ->
    parsedResponse = []

    for uid, draftID of response
      draftID = {}
      draftID["uid"] = uid
      draftID["draftID"] = draftID
      parsedResponse.push(draftID)

    return parsedResponse

  getEmailDraftID: (emailUID) ->
    emailDraftIDs = @filter((draftID) ->
      draftID.get("uid") is emailUID
    )

    return if emailDraftIDs.length > 0 then emailDraftIDs[0].get("draftID") else null
