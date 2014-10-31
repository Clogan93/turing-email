class TuringEmailApp.Models.EmailThread extends Backbone.Model
  idAttribute: "uid"
  
  @setThreadParsedProperties: (threadParsed, messages, messageInfo) ->
    threadParsed.num_messages = messages.length
    threadParsed.snippet = messageInfo.snippet
    
    emailParsed = {}
    TuringEmailApp.Models.Email.parseHeaders(emailParsed, messageInfo.payload.headers)
  
    threadParsed.from_name = emailParsed.from_name
    threadParsed.from_address = emailParsed.from_address
    threadParsed.date = emailParsed.date
    threadParsed.subject = emailParsed.subject
    
    folderIDs = []
  
    threadParsed.seen = true
    for message in messages
      if message.labelIds?
        folderIDs = folderIDs.concat(message.labelIds)
        threadParsed.seen = false if message.labelIds.indexOf("UNREAD") != -1
  
    threadParsed.folder_ids = _.uniq(folderIDs)
    
    return threadParsed

  @createGmailLabelRequest: (labelName, labelListVisibility="labelShow", messageListVisibility="show") ->
    gapi.client.gmail.users.labels.create({userId: "me"},
                                          {name: labelName, labelListVisibility: labelListVisibility, messageListVisibility: messageListVisibility})
    
  @removeGmailLabelRequest: (emailThreadUID, labelID) ->
    gapi.client.gmail.users.threads.modify({userId: "me", id: emailThreadUID}, {removeLabelIds: [labelID]})
    
  @removeFromFolder: (app, emailThreadUIDs, emailFolderID, success, error) ->
    if emailFolderID == "SENT"
      error?()
      return
      
    for emailThreadUID in emailThreadUIDs
      googleRequest(
        app
        => @removeGmailLabelRequest(emailThreadUID, labelID)
        success
        error
      )

  @trashRequest: (emailThreadUID) ->
    gapi.client.gmail.users.threads.trash(userId: "me", id: emailThreadUID)
    
  @trash: (app, emailThreadUIDs) ->
    for emailThreadUID in emailThreadUIDs
      googleRequest(
        app
        => @trashRequest(emailThreadUID)
      )

  @deleteDraftRequest: (draftID) ->
    gapi.client.gmail.users.drafts.delete(userId: "me", id: draftID)

  @deleteDraft: (app, draftIDs) ->
    for draftID in draftIDs
      googleRequest(
        app
        => @deleteDraftRequest(draftID)
      )

  @applyGmailLabelRequest: (emailThreadUID, labelID) ->
    gapi.client.gmail.users.threads.modify({userId: "me", id: emailThreadUID}, {addLabelIds: [labelID]})
    
  @applyGmailLabel: (app, emailThreadUIDs, labelID, labelName, success, error) ->
    run = (response) =>
      if response?
        labelID = response.result.id
      
      for emailThreadUID in emailThreadUIDs
        googleRequest(
          app
          => @applyGmailLabelRequest(emailThreadUID, labelID)
          success
          error
        )

    if labelID?
      run()
    else
      googleRequest(
        app
        => @createGmailLabelRequest(labelName)
        (response) => run(response)
        error
      )
        
  @modifyGmailLabelsRequest: (emailThreadUID, addLabelIDs, removeLabelIDs) ->
    removeLabelIDs = _.filter(removeLabelIDs, (labelID) => labelID != "SENT");

    gapi.client.gmail.users.threads.modify({userId: "me", id: emailThreadUID},
                                           {addLabelIds: addLabelIDs, removeLabelIds: removeLabelIDs})
      
  @moveToFolder: (app, emailThreadUIDs, folderID, folderName, currentFolderIDs, success, error) ->
    run = (response) =>
      if response?
        folderID = response.result.id

      for emailThreadUID in emailThreadUIDs
        googleRequest(
          app
          => @modifyGmailLabelsRequest(emailThreadUID, [folderID], currentFolderIDs)
          success
          error
        )

    if folderID?
      run()
    else
      googleRequest(
        app
        => @createGmailLabelRequest(folderName)
        (response) => run(response)
        error
      )

  validation:
    uid:
      required: true

    emails:
      required: true

  initialize: (attributes, options) ->
    @app = options.app
    @emailThreadUID = options.emailThreadUID
    
    @listenTo(this, "change:seen", @seenChanged)

  ###############
  ### Network ###
  ###############

  load: (options, force=false) ->
    if @get("loaded") and not force
      options.success?()
    else
      return if @loading

      @loading = true
      @emailThreadUID = @get("uid")

      options ?= {}
      success = options.success
      options.success = =>
        draftInfo = @get("draftInfo")
        if draftInfo
          message = _.find(@get("emails"), (emailJSON) -> emailJSON.uid == draftInfo.message.id)
          message.draft_id = draftInfo.id if message?
        
        @set("loaded", true)
        @loading = false
        success?()

      error = options.error
      options.error = =>
        @loading = false
        error?()

      @fetch(options)

  sync: (method, model, options) ->
    if method != "read"
      super(method, model, options)
    else
      googleRequest(
        @app
        => @threadsGetRequest()
        (response) => @processThreadsGetRequest(response, options)
        options.error
      )

      @trigger("request", model, null, options)

  threadsGetRequest: ->
    return gapi.client.gmail.users.threads.get(userId: "me", id: @emailThreadUID)

  processThreadsGetRequest: (response, options) ->
    threadJSON = @parseThreadInfo(response.result)
    options.success?(threadJSON)

  parseThreadInfo: (threadInfo) ->
    lastMessageInfo = _.last(threadInfo.messages)
    threadParsed = uid: threadInfo.id
    TuringEmailApp.Models.EmailThread.setThreadParsedProperties(threadParsed, threadInfo.messages, lastMessageInfo)

    threadParsed.emails = _.map(threadInfo.messages, (message) =>
      emailParsed = {}

      emailParsed.uid = message.id
      emailParsed.snippet = message.snippet
      emailParsed.folder_ids = message.labelIds
      emailParsed.seen = not message.labelIds? || message.labelIds.indexOf("UNREAD") == -1

      TuringEmailApp.Models.Email.parseHeaders(emailParsed, message.payload.headers)

      if message.payload.body.size > 0
        emailParsed.body_text_encoded = message.payload.body.data
        emailParsed.body_text = base64_decode_urlsafe(emailParsed.body_text_encoded)

      TuringEmailApp.Models.Email.parseBody(emailParsed, message.payload.parts)

      return emailParsed
    )

    return threadParsed
      
  ##############
  ### Events ###
  ##############

  threadsModifyUnreadRequest: (seenValue) ->
    if seenValue
      body = removeLabelIds: ["UNREAD"]
    else
      body = addLabelIds: ["UNREAD"]
      
    gapi.client.gmail.users.threads.modify(
      {userId: "me", id: @get("uid")},
      body
    )
  
  seenChanged: (model, seenValue)->
    googleRequest(
      @app
      => @threadsModifyUnreadRequest(seenValue)
    )

  ###############
  ### Getters ###
  ###############

  sortedEmails: ->
    emails = @get("emails")
    return emails.sort (a, b) => a.date - b.date
    
  ###############
  ### Actions ###  
  ###############
    
  removeFromFolder: (emailFolderID) ->
    TuringEmailApp.Models.EmailThread.removeFromFolder(@app, [@get("uid")], emailFolderID)
  
  trash: ->
    TuringEmailApp.Models.EmailThread.trash(@app, [@get("uid")])
    
  deleteDraft: ->
    TuringEmailApp.Models.EmailThread.deleteDraft(@app, [@get("draft_id")])

  applyGmailLabel: (labelID, labelName) ->
    TuringEmailApp.Models.EmailThread.applyGmailLabel(@app, [@get("uid")], labelID, labelName,
      (data) =>
        @trigger("change:folder", this, data)
    )

  moveToFolder: (folderID, folderName) ->
    TuringEmailApp.Models.EmailThread.moveToFolder(@app, [@get("uid")], folderID, folderName, @get("folder_ids"),
      (data, status) =>
        @trigger("change:folder", this, data)
    )

  ##################
  ### Formatters ###
  ##################

  numEmailsText: () ->
    emails = @get("emails")
    num_messages = if emails? then emails.length else @get("num_messages")
    return if num_messages is 1 then "" else "(" + num_messages + ")"

  fromPreview: ->
    fromAddress = @get("from_address")
    fromName = @get("from_name")
    
    if fromAddress is TuringEmailApp.models.user.get("email")
      return "me " + @numEmailsText()
    else
      return (if fromName? and fromName.trim() != "" then fromName else fromAddress) + " " + @numEmailsText() 

  subjectPreview: ->
    subject = @get("subject")
    return if subject is "" then "(no subject)" else subject

  datePreview: ->
    return TuringEmailApp.Models.Email.localDateString(@get("date"))
