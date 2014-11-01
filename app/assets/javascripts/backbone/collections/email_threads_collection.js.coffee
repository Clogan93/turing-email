class TuringEmailApp.Collections.EmailThreadsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailThread
  url: "/api/v1/email_threads/in_folder?folder_id=INBOX"

  initialize: (models, options) ->
    @app = options.app
    @demoMode = if options.demoMode? then options.demoMode else true

    @listenTo(this, "remove", @modelRemoved)
    @listenTo(this, "reset", @modelsReset)

    @resetPageTokens()
    @folderIDIs(options?.folderID) if options?.folderID?
  
  ##############
  ### Events ###
  ##############
    
  modelRemoved: (model) ->
    model.trigger("removedFromCollection", this)

  modelsReset: (models, options) ->
    options.previousModels.forEach(@modelRemoved, this)

  ###############
  ### Network ###
  ###############

  sync: (method, collection, options) ->
    if method != "read" || @demoMode
      super(method, collection, options)
    else
      options ?= {}
      options.folderID = @folderID

      googleRequest(
        @app
        => @threadsListRequest(options)
        (response) => @processThreadsListRequest(response, options)
        options.error
      )

      @trigger("request", collection, null, options)

  threadsListRequest: (options) ->
    params =
      userId: "me"
      maxResults: TuringEmailApp.Models.UserSettings.EmailThreadsPerPage

    params["pageToken"] = @pageTokens[@pageTokenIndex] if @pageTokens[@pageTokenIndex]?
      
    if options.folderID is "DRAFT"
      gapi.client.gmail.users.drafts.list(params)
    else
      params["fields"] = "nextPageToken,threads(id)"
      params["labelIds"] = options.folderID if options.folderID?
      params["q"] = options.query if options?.query
  
      gapi.client.gmail.users.threads.list(params)

  processThreadsListRequest: (response, options) ->
    @pageTokens[@pageTokenIndex + 1] = response.result.nextPageToken if response.result.nextPageToken?
    @pageTokens = @pageTokens.slice(0, @pageTokenIndex + 2)

    if response.result.threads?
      @loadThreads(response.result.threads, options)
    else if response.result.drafts?
      @loadDrafts(response.result.drafts, options)
    else
      options.success?([])

  loadThreads: (threadsListInfo, options) ->
    googleRequest(
      @app
      => @threadsGetBatch(threadsListInfo)
      (response) => @processThreadsGetBatch(response, options)
      options.error
    )

  loadDrafts: (draftsListInfo, options) ->
    options.draftsListInfo = draftsListInfo

    threadsListInfo = []
    for draftInfo in draftsListInfo
      threadsListInfo.push(id: draftInfo.message.threadId)
    
    googleRequest(
      @app
      => @threadsGetBatch(threadsListInfo)
      (response) => @processThreadsGetBatch(response, options)
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
    
  processThreadsGetBatch: (response, options) ->
    threadResults = _.values(response.result)
    threadsInfo = _.pluck(threadResults, "result")
    @loadThreadsPreview(threadsInfo, options)

  loadThreadsPreview: (threadsInfo, options) ->
    googleRequest(
      @app
      => @messagesGetBatch(threadsInfo)
      (response) => @processMessagesGetBatch(response, threadsInfo, options)
      options.error
    )

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
    threads = []

    for threadInfo in threadsInfo
      if options.folderID != "TRASH"
        inTrash = true
  
        for message in threadInfo.messages
          if not message.labelIds? || message.labelIds.indexOf("TRASH") == -1
            inTrash = false
            break
        
        continue if inTrash
          
      lastMessage =_.last(threadInfo.messages)
      lastMessageResponse = response.result[lastMessage.id]

      if lastMessageResponse.status == 200
        threads.push(@threadFromMessageInfo(threadInfo, lastMessageResponse.result))
      else
        reason = lastMessageResponse.result
        break

    if reason?
      options.error(reason)
    else
      threads.sort((a, b) => b.date - a.date)
      
      if options.draftsListInfo?
        for draftInfo in options.draftsListInfo
          thread = _.find(threads, (thread) -> thread.uid == draftInfo.message.threadId);
          thread.draftInfo = draftInfo if thread?
      
      options.success(threads)

  threadFromMessageInfo: (threadInfo, lastMessageInfo) ->
    threadParsed = uid: threadInfo.id
    TuringEmailApp.Models.EmailThread.setThreadParsedProperties(threadParsed, threadInfo.messages, lastMessageInfo)

    return threadParsed

  parse: (threadsJSON, options) ->
    if @demoMode
      TuringEmailApp.Models.EmailThread.SetThreadPropertiesFromJSON(threadJSON, @demoMode) for threadJSON in threadsJSON

    return threadsJSON
    
  ###############
  ### Setters ###
  ###############

  resetPageTokens: ->
    @pageTokens = [null]
    @pageTokenIndex = 0

  folderIDIs: (folderID) ->
    @resetPageTokens() if @folderID != folderID

    @folderID = folderID
    @setupURL() if @demoMode
    
    @trigger("change:folderID", this, @folderID)

  pageTokenIndexIs: (pageTokenIndex) ->
    @pageTokenIndex = parseInt(pageTokenIndex)
    @pageTokenIndex = Math.min(@pageTokens.length - 1, @pageTokenIndex) if !@demoMode

    @setupURL() if @demoMode

    @trigger("change:pageTokenIndex", this, @pageTokenIndex)
  
  # TODO write tests
  setupURL: ->
    @url = "/api/v1/email_threads/in_folder?folder_id=" + @folderID if @folderID
    @url += "&page=" + (@pageTokenIndex + 1) if @pageTokenIndex
    
  ###############
  ### Getters ###
  ###############

  hasNextPage: ->
    if @demoMode
      return @length % TuringEmailApp.Models.UserSettings.EmailThreadsPerPage == 0
    else
      return @pageTokenIndex < @pageTokens.length - 1

  hasPreviousPage: ->
    return @pageTokenIndex > 0
