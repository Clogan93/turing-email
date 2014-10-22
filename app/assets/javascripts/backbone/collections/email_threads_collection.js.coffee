class TuringEmailApp.Collections.EmailThreadsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailThread
  url: "/api/v1/email_threads/in_folder?folder_id=INBOX"

  initialize: (models, options) ->
    @app = options.app
    @listenTo(this, "remove", @modelRemoved)
    @listenTo(this, "reset", @modelsReset)

    @clearPageTokens()
    @folderIDIs(options?.folderID) if options?.folderID?
  
  ##############
  ### Events ###
  ##############
    
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
  
  threadFromMessageInfo: (threadInfo, lastMessageInfo) ->
    threadParsed =
      uid: threadInfo.id
      snippet: lastMessageInfo.snippet
      num_messages: threadInfo.messages.length

    if lastMessageInfo.payload?.headers?
      emailParsed = {}
      TuringEmailApp.Models.Email.parseHeaders(emailParsed, lastMessageInfo.payload.headers)

      threadParsed.from_name = emailParsed.from_name
      threadParsed.from_address = emailParsed.from_address
      threadParsed.date = emailParsed.date
      threadParsed.subject = emailParsed.subject

    folderIDs = []

    threadParsed.seen = true
    for message in threadInfo.messages
      if message.labelIds?
        folderIDs = folderIDs.concat(message.labelIds)
        threadParsed.seen = false if message.labelIds.indexOf("UNREAD") != -1

    threadParsed.folder_ids = _.uniq(folderIDs)
        
    return threadParsed

  messagesGetBatch: (threadsInfo) ->
    batch = gapi.client.newBatch();

    for threadInfo in threadsInfo
      lastMessage =_.last(threadInfo.messages)

      request = gapi.client.gmail.users.messages.get(
        userId: "me"
        id: lastMessage.id
        format: "metadata"
        metadataHeaders: ["date", "from", "subject"]
        fields: "payload,snippet"
      )
      batch.add(request, id: lastMessage.id)

    return batch
    
  processMessagesGetBatch: (response, threadsInfo, options) ->
    threads = _.map(threadsInfo, (threadInfo) =>
      return null if reason?

      lastMessage =_.last(threadInfo.messages)
      lastMessageResponse = response.result[lastMessage.id]

      if lastMessageResponse.status == 200
        return @threadFromMessageInfo(threadInfo, lastMessageResponse.result)
      else
        reason = lastMessageResponse.result
    )

    if reason?
      options.error(reason)
    else
      threads.sort((a, b) => b.date - a.date)
      options.success(threads)

  loadThreadsPreview: (threadsInfo, options) ->
    googleRequest(
      @app
      => @messagesGetBatch(threadsInfo)
      (response) => @processMessagesGetBatch(response, threadsInfo, options)
      options.error
    )
    
  threadsGetBatch: (threadsListInfo) ->
    batch = gapi.client.newBatch();

    for threadInfo in threadsListInfo
      request = gapi.client.gmail.users.threads.get(
        userId: "me"
        id: threadInfo.id
        fields: "id,historyId,messages(id,labelIds)"
      )
      batch.add(request)

    return batch

  loadThreads: (threadsListInfo, options) ->
    googleRequest(
      @app
      => @threadsGetBatch(threadsListInfo)
      (response) =>
        threadResults = _.values(response.result)
        threadsInfo = _.pluck(threadResults, "result")
        @loadThreadsPreview(threadsInfo, options)

      options.error
    )
    
  # does NOT trigger('request', model, xhr, options);
  sync: (method, model, options) ->
    if method != "read"
      super(method, model, options)
    else
      params =
        userId: "me"
        maxResults: TuringEmailApp.Models.UserSettings.EmailThreadsPerPage
        fields: "nextPageToken,threads(id)"
        
      params["labelIds"] = @folderID if @folderID?
      params["pageToken"] = @pageTokens[@pageTokenIndex] if @pageTokens[@pageTokenIndex]?
      params["q"] = options.query if options?.query

      googleRequest(
        @app
        => gapi.client.gmail.users.threads.list(params)
        
        (response) =>
          @pageTokens[@pageTokenIndex + 1] = response.result.nextPageToken if response.result.nextPageToken?
          @pageTokens = @pageTokens.slice(0, @pageTokenIndex + 2)

          if response.result.threads?
            @loadThreads(response.result.threads, options)
          else
            options.success?([])
            
        options.error
      )

      model.trigger("request", model, null, options);
