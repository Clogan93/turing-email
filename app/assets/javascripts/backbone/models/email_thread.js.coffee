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
    return $.post("/api/v1/email_threads/apply_gmail_label", postData)

  @moveToFolder: (emailThreadUIDs, folderID, folderName) ->
    postData =
      email_thread_uids: emailThreadUIDs

    postData.email_folder_id = folderID if folderID?
    postData.email_folder_name = folderName if folderName?

    # TODO error handling
    return $.post("/api/v1/email_threads/move_to_folder", postData)
    
  validation:
    uid:
      required: true

    emails:
      required: true

  initialize: (attributes, options) ->
    @app = options.app
    @emailThreadUID = options.emailThreadUID
    
    @listenTo(this, "change:seen", @seenChanged)

  load: (options, force=false) ->
    if @loaded? and not force
      options.success?()
    else
      return if @loading?
      
      @loading = true
      @emailThreadUID = @get("uid")
      
      options ?= {}
      success = options.success
      options.success = =>
        @loaded = true
        @loading = false
        success?()
        
      error = options.error
      options.error = =>
        @loading = false
        error?()
        
      @fetch(options)

  ###############
  ### Network ###
  ###############
    
  parseThreadInfo: (threadInfo, options) ->
    threadParsed = {}

    threadParsed.uid = threadInfo.id
    threadParsed.emails = _.map(threadInfo.messages, (message) =>
      emailParsed = {}

      emailParsed.uid = message.id
      emailParsed.snippet = message.snippet
      emailParsed.folder_ids = message.labelIds
      emailParsed.seen = not message.labelIds? || message.labelIds.indexOf("UNREAD") == -1

      TuringEmailApp.Models.Email.parseHeaders(emailParsed, message.payload.headers)

      emailParsed.body_text_encoded = message.payload.body.data if message.payload.body.size > 0
      TuringEmailApp.Models.Email.parseBody(emailParsed, message.payload.parts)

      return emailParsed
    )

    return threadParsed

  sync: (method, model, options) ->
    if method != "read"
      super(method, model, options)
    else
      googleRequest(
        @app
        => gapi.client.gmail.users.threads.get(userId: "me", id: @emailThreadUID)

        (response) =>
          threadJSON = @parseThreadInfo(response.result)
          options.success?(threadJSON)

        options.error
      )

      model.trigger("request", model, null, options);
    
  ##############
  ### Events ###
  ##############

  seenChanged: (model, seenValue)->
    if seenValue
      body = removeLabelIds: ["UNREAD"]
    else
      body = addLabelIds: ["UNREAD"]

    googleRequest(
      @app
      =>
        gapi.client.gmail.users.threads.modify(
          {userId: "me", id: @get("uid")},
          body
        )
    )

  ###############
  ### Getters ###
  ###############

  folderIDs: ->
    if not @loaded?
      return @get("folder_ids")
    else
      emails = @get("emails")
      folderIDs = []
  
      for email in emails
        folderIDs = folderIDs.concat email["folder_ids"]
  
      return _.uniq(folderIDs)

  sortedEmails: ->
    emails = @get("emails")
    return emails.sort (a, b) => a["date"] - b["date"]
    
  ###############
  ### Actions ###  
  ###############
    
  # TODO write tests
  removeFromFolder: (emailFolderID) ->
    TuringEmailApp.Models.EmailThread.removeFromFolder([@get("uid")], emailFolderID)
  
  # TODO write tests
  trash: ->
    TuringEmailApp.Models.EmailThread.trash([@get("uid")])

  # TODO write tests
  applyGmailLabel: (labelID, labelName) ->
    TuringEmailApp.Models.EmailThread.applyGmailLabel([@get("uid")], labelID, labelName).done(
      (data, status) =>
        @trigger("change:folder", this, data)
    )

  # TODO write tests
  moveToFolder: (folderID, folderName) ->
    TuringEmailApp.Models.EmailThread.moveToFolder([@get("uid")], folderID, folderName).done(
      (data, status) =>
        @trigger("change:folder", this, data)
    )

  ##################
  ### Formatters ###
  ##################

  numEmailsText: () ->
    emails = @get("emails")
    num_messages = if emails? then emails.length else @get("num_messages")
    return if num_messages is 1 then "" else " (" + num_messages + ")"

  fromPreview: ->
    fromAddress = @get("from_address")
    fromName = @get("from_name")
    
    if fromAddress is TuringEmailApp.models.user.get("email")
      return "me " + @numEmailsText()
    else
      return (if fromName? then fromName else fromAddress) + " " + @numEmailsText() 

  subjectPreview: ->
    subject = @get("subject")
    return if subject is "" then "(no subject)" else subject

  datePreview: ->
    return TuringEmailApp.Models.Email.localDateString(@get("date"))
