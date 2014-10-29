class TuringEmailApp.Collections.EmailFoldersCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailFolder
  
  initialize: (models, options) ->
    @app = options.app
    @listenTo(this, "remove", @modelRemoved)
    @listenTo(this, "reset", @modelsReset)

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
        => @labelsListRequest()
        (response) => @loadLabels(response.result.labels, options)
        options.error
      )

      @trigger("request", collection, null, options)

  labelsListRequest: ->
    gapi.client.gmail.users.labels.list(userId: "me", fields: "labels/id")

  loadLabels: (labelsListInfo, options) ->
    googleRequest(
      @app
      => @labelsGetBatch(labelsListInfo)
      (response) => @processLabelsGetBatch(response, options)
      options.error
    )

  labelsGetBatch: (labelsListInfo) ->
    batch = gapi.client.newBatch();

    for labelInfo in labelsListInfo
      request = gapi.client.gmail.users.labels.get(
        userId: "me"
        id: labelInfo.id
      )
      batch.add(request)

    return batch

  processLabelsGetBatch: (response, options) ->
    labelsResults = _.values(response.result)
    labelsInfo = _.pluck(labelsResults, "result")
    options.success(labelsInfo)

  parse: (labelsInfo, options) ->
    labelsParsed = _.map(labelsInfo, (label) =>
      labelParsed = {}
      labelParsed.label_id = label.id
      labelParsed.name = label.name
      labelParsed.message_list_visibility = label.messageListVisibility
      labelParsed.label_list_visibility = label.labelListVisibility
      labelParsed.label_type = label.type
      labelParsed.num_threads = label.threadsTotal
      labelParsed.num_unread_threads = label.threadsUnread

      return labelParsed
    )

    return labelsParsed
