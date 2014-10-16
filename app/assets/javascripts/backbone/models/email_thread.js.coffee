class TuringEmailApp.Models.EmailThread extends Backbone.Model
  @removeFromFolder: (emailThreadUIDs, emailFolderID) ->
    postData =
      email_thread_uids:  emailThreadUIDs
      email_folder_id: emailFolderID

    # TODO error handling
    $.post "/api/v1/email_threads/remove_from_folder", postData

  @trash: (emailThreadUIDs) ->
    postData =
      email_thread_uids:  emailThreadUIDs

    # TODO error handling
    $.post "/api/v1/email_threads/trash", postData

  @applyGmailLabel: (emailThreadUIDs, labelID, labelName) ->
    postData =
      email_thread_uids: emailThreadUIDs

    postData.gmail_label_id = labelID if labelID?
    postData.gmail_label_name = labelName if labelName?

    # TODO error handling
    $.post "/api/v1/email_threads/apply_gmail_label", postData

  @moveToFolder: (emailThreadUIDs, folderID, folderName) ->
    postData =
      email_thread_uids: emailThreadUIDs

    postData.email_folder_id = folderID if folderID?
    postData.email_folder_name = folderName if folderName?

    # TODO error handling
    $.post "/api/v1/email_threads/move_to_folder", postData
    
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
      if email.seen != seenValue
        email.seen = seenValue
        emailUIDs.push email.uid
    
    return if emailUIDs.length is 0
        
    postData.email_uids = emailUIDs
    postData.seen = seenValue

    url = "/api/v1/emails/set_seen"
    $.post url, postData
    
    @trigger("change:seen", this, seenValue)

  # TODO write tests
  removeFromFolder: (emailFolderID) ->
    TuringEmailApp.Models.EmailThread.removeFromFolder([@get("uid")], emailFolderID)
  
  # TODO write tests
  trash: ->
    TuringEmailApp.Models.EmailThread.trash([@get("uid")])

  # TODO write tests
  applyGmailLabel: (labelID, labelName) ->
    TuringEmailApp.Models.EmailThread.applyGmailLabel([@get("uid")], labelID, labelName)

  # TODO write tests
  moveToFolder: (folderID, folderName) ->
    TuringEmailApp.Models.EmailThread.moveToFolder([@get("uid")], folderID, folderName)

  folderIDs: ->
    emails = @get("emails")
    folderIDs = []

    for email in emails
      folderIDs.push gmailLabel["label_id"] for gmailLabel in email["gmail_labels"] if email["gmail_labels"]?
      folderIDs.push imapFolder["folder_id"] for imapFolder in email["imap_folders"] if email["imap_folders"]?

    return _.uniq(folderIDs)

  ##################
  ### Formatters ###
  ##################

  numEmailsText: (emails) ->
    return "" if emails.length is 1
    return " (" + emails.length.toString() + ")"

  fromPreview: ->
    emails = @get("emails")
    mostRecentEmail = emails[0]
    
    if mostRecentEmail.from_address isnt TuringEmailApp.models.user.get("email")
      return if mostRecentEmail.from_name? then mostRecentEmail.from_name + @numEmailsText(emails) else mostRecentEmail.from_address + @numEmailsText(emails)
    
    if emails.length is 1
      return "me"

    for email, index in emails
      continue if index is 0

      if email.from_address isnt TuringEmailApp.models.user.get("email")
        return if email.from_name? then email.from_name + ", me" + @numEmailsText(emails) else email.from_address + ", me" + @numEmailsText(emails)

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
