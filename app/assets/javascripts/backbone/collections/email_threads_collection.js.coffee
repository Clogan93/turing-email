class TuringEmailApp.Collections.EmailThreadsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailThread
  url: "/api/v1/email_threads/in_folder?folder_id=INBOX"

  initialize: (models, options) ->
    @app = options.app
    @listenTo(this, "remove", @modelRemoved)
    @listenTo(this, "reset", @modelsReset)

    @clearPageTokens()
    @folderIDIs(options?.folderID) if options?.folderID?
  
  modelRemoved: (model) ->
    model.trigger("removedFromCollection", this)

  modelsReset: (models, options) ->
    options.previousModels.forEach(@modelRemoved, this)

  ###############
  ### Getters ###
  ###############

  getEmailThread: (emailThreadUID) ->
    emailThreads = @filter((emailThread) ->
      emailThread.get("uid") is emailThreadUID
    )

    return if emailThreads.length > 0 then emailThreads[0] else null

  hasNextPage: ->
    return @pageTokenIndex < @pageTokens.length - 1

  hasPreviousPage: ->
    return @pageTokenIndex > 0
      
  ###############
  ### Setters ###
  ###############
  
  clearPageTokens: ->
    @pageTokens = [null]
    @pageTokenIndex = 0
  
  folderIDIs: (folderID) ->
    @clearPageTokens() if @folderID != folderID
    
    @folderID = folderID
    @trigger("change:folderID", this, @folderID)

  pageTokenIndexIs: (pageTokenIndex) ->
    @pageTokenIndex = parseInt(pageTokenIndex)
    @pageTokenIndex = Math.min(@pageTokens.length - 1, @pageTokenIndex)
    
    @trigger("change:pageTokenIndex", this, @pageTokenIndex)

  ###############
  ### Network ###
  ###############
  
  parseHeaders: (emailParsed, headers) ->
    headersMap =
      "message-id": "message_id"
      "list-id": "list_id"
      "date": "date"
      "subject": "subject"
      "to": "tos"
      "cc": "ccs"
      "bcc": "bccs"

    emailHeadersMap =
      "from": "from_"
      "sender": "sender_"
      "reply_to": "reply_to_"

    for header in headers
      found = false

      headerName = header.name.toLowerCase()
      parsedKey = headersMap[headerName]
      if parsedKey?
        if headerName is "date"
          emailParsed[parsedKey] = new Date(header.value)
        else
          emailParsed[parsedKey] = header.value

        found = true

      if not found
        parsedPrefix = emailHeadersMap[headerName]
        if parsedPrefix?
          parsedEmail = EmailAddressParser.parseOneAddress(header.value)
          emailParsed[parsedPrefix + "name"] = parsedEmail.name
          emailParsed[parsedPrefix + "address"] = parsedEmail.address
    
  parseBody: (emailParsed, parts) ->
    return if not parts?
    
    foundText = false
    foundHTML = false
  
    for part in parts
      if not foundText and part.mimeType.toLowerCase() == "text/plain" and part.body.size > 0
        emailParsed.text_part_encoded = part.body.data
        foundText = true

      if not foundHTML and part.mimeType.toLowerCase() == "text/html" and part.body.size > 0
        emailParsed.html_part_encoded = part.body.data
        foundHTML = true

      if not emailParsed.text_part_encoded? or not emailParsed.html_part_encoded?
        @parseBody(emailParsed, part.parts)
            
  parse: (threads, options) ->
    threadsParsed = _.map(threads, (thread) =>
      threadParsed = {}

      threadParsed.uid = thread.id
      threadParsed.emails = _.map(thread.messages, (message) =>
        emailParsed = {}

        emailParsed.uid = message.id
        emailParsed.snippet = message.snippet
        emailParsed.folder_ids = message.labelIds
        emailParsed.seen = not message.labelIds? || message.labelIds.indexOf("UNREAD") == -1

        @parseHeaders(emailParsed, message.payload.headers)

        emailParsed.body_text_encoded = message.payload.body.data if message.payload.body.size > 0
        @parseBody(emailParsed, message.payload.parts)
        
        return emailParsed
      )

      return threadParsed
    )
    
    threadsParsed.sort((a, b) =>
      return _.last(b["emails"])["date"] - _.last(a["emails"])["date"]
    )
    
    return threadsParsed

  # does NOT trigger('request', model, xhr, options);
  sync: (method, model, options) ->
    if method is not "read"
      super(method, model, options)
      Backbone.sync
    else
      params =
        userId: "me"
        maxResults: TuringEmailApp.Models.UserSettings.EmailThreadsPerPage

      params["labelIds"] = @folderID if @folderID?
      params["pageToken"] = @pageTokens[@pageTokenIndex] if @pageTokens[@pageTokenIndex]?
      request = gapi.client.gmail.users.threads.list(params)

      google_execute_request(
        request
        
        (response) =>
          @pageTokens[@pageTokenIndex + 1] = response.result.nextPageToken if response.result.nextPageToken?
          @pageTokens = @pageTokens.slice(0, @pageTokenIndex + 2)
          
          if response.result.threads?
            batch = gapi.client.newBatch();
            
            for thread in response.result.threads
              request = gapi.client.gmail.users.threads.get(userId: "me", id: thread.id)
              batch.add(request)

            google_execute_request(
              batch
            
              (response) ->
                threadResults = _.values(response.result)
                threads = _.pluck(threadResults, "result")
                options.success?(threads)
                
              (reason) -> options.error?(reason)
              this
              => @app.refreshGmailAPIToken().done(=> @sync(method, model, options))
            )
          else
            options.success?([])
            
        (reason) -> options.error?(reason)
        this
        => @app.refreshGmailAPIToken().done(=> @sync(method, model, options))
      )
      