class TuringEmailApp.Collections.EmailDraftIDsCollection extends Backbone.Collection
  url: '/api/v1/email_accounts/get_draft_ids.json'

  parse: (response, options) ->
    parsedResponse = []

    for uid, draftID of response
      draftData = {}
      draftData["uid"] = uid
      draftData["draftID"] = draftID
      parsedResponse.push(draftData)

    return parsedResponse

  getEmailDraftID: (emailUID) ->
    emailDraftIDs = @filter((draftData) ->
      draftData.get("uid") is emailUID
    )

    return if emailDraftIDs.length > 0 then emailDraftIDs[0].get("draftID") else null
