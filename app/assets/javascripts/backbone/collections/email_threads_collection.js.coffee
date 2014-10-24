class TuringEmailApp.Collections.EmailThreadsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailThread

  initialize: (models, options) ->
    @app = options.app
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
    if method != "read"
      super(method, collection, options)
    else
      googleRequest(
        @app
        => @threadsListRequest(options)
        (response) => @processThreadsListRequest(response, options)
        options.error
      )

      @trigger("request", collection, null, options);

  threadsListRequest: (options) ->
    params =
      userId: "me"
      maxResults: TuringEmailApp.Models.UserSettings.EmailThreadsPerPage
      fields: "nextPageToken,threads(id)"

    params["labelIds"] = @folderID if @folderID?
    params["pageToken"] = @pageTokens[@pageTokenIndex] if @pageTokens[@pageTokenIndex]?
    params["q"] = options.query if options?.query

    gapi.client.gmail.users.threads.list(params)

  processThreadsListRequest: (response, options) ->
    @pageTokens[@pageTokenIndex + 1] = response.result.nextPageToken if response.result.nextPageToken?
    @pageTokens = @pageTokens.slice(0, @pageTokenIndex + 2)

    if response.result.threads?
      @loadThreads(response.result.threads, options)
    else
      options.success?([])

  loadThreads: (threadsListInfo, options) ->
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

  threadFromMessageInfo: (threadInfo, lastMessageInfo) ->
    threadParsed = uid: threadInfo.id
    TuringEmailApp.Models.EmailThread.setThreadParsedProperties(threadParsed, threadInfo.messages, lastMessageInfo)

    return threadParsed

  ###############
  ### Setters ###
  ###############

  resetPageTokens: ->
    @pageTokens = [null]
    @pageTokenIndex = 0

  folderIDIs: (folderID) ->
    @resetPageTokens() if @folderID != folderID

    @folderID = folderID
    @trigger("change:folderID", this, @folderID)

  pageTokenIndexIs: (pageTokenIndex) ->
    @pageTokenIndex = parseInt(pageTokenIndex)
    @pageTokenIndex = Math.min(@pageTokens.length - 1, @pageTokenIndex)

    @trigger("change:pageTokenIndex", this, @pageTokenIndex)
    
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
