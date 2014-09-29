class TuringEmailApp.Models.EmailThread extends Backbone.Model
  # TODO write tests
  @removeFromFolder: (emailThreadUIDs, emailFolderID) ->
    postData =
      email_thread_uids:  emailThreadUIDs
      email_folder_id: emailFolderID

    # TODO error handling
    $.post "/api/v1/email_threads/remove_from_folder", postData

  # TODO write tests
  @trash: (emailThreadUIDs) ->
    postData =
      email_thread_uids:  emailThreadUIDs

    # TODO error handling
    $.post "/api/v1/email_threads/trash", postData

  validation:
    uid:
      required: true

    emails:
      required: true

  initialize: (attributes, options) ->
    @url = "/api/v1/email_threads/show/" + options.emailThreadUID if options?.emailThreadUID

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

  # TODO write tests
  removeFromFolder: (emailFolderID) ->
    TuringEmailApp.Models.EmailThread.removeFromFolder([@get("uid")], emailFolderID)
  
  # TODO write tests
  trash: ->
    TuringEmailApp.Models.EmailThread.trash([@get("uid")])
    
  fromPreview: ->
    emails = @get("emails")
    mostRecentEmail = emails[0]
    
    if mostRecentEmail.from_address isnt TuringEmailApp.models.user.get("email")
      return if mostRecentEmail.from_name? then mostRecentEmail.from_name else mostRecentEmail.from_address
    
    if emails.length is 1
      return "me"

    for email, index in emails
      continue if index is 0

      if email.from_address isnt TuringEmailApp.models.user.get("email")
        return if email.from_name? then email.from_name + ", me" else email.from_address + ", me"

    return "me"

  subjectPreview: ->
    emails = @get("emails")
    mostRecentEmail = emails[0]

    if mostRecentEmail.from_address isnt TuringEmailApp.models.user.get("email") or emails.length is 1
      return if mostRecentEmail.subject isnt "" then mostRecentEmail.subject else "(no subject)"

    for email, index in emails
      continue if index is 0
      
      if email.from_address isnt TuringEmailApp.models.user.get("email")
        return if email.subject isnt "" then email.subject else "(no subject)"

    return if mostRecentEmail.subject isnt "" then mostRecentEmail.subject else "(no subject)"

  datePreview: ->
    emails = @get("emails")
    return "" if emails.length is 0
    
    dateString = emails[0]["date"]
    return TuringEmailApp.Models.Email.localDateString(dateString)
