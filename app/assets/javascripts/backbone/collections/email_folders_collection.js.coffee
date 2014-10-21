class TuringEmailApp.Collections.EmailFoldersCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailFolder
  url: '/api/v1/email_folders'

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

  loadLabels: (labelsListInfo, options, retry) ->
    batch = gapi.client.newBatch();

    for labelinfo in labelsListInfo
      request = gapi.client.gmail.users.labels.get(
        userId: "me"
        id: labelinfo.id
      )
      batch.add(request)
  
    google_execute_request(
      batch
  
      (response) =>
        labelsResults = _.values(response.result)
        labelsInfo = _.pluck(labelsResults, "result")
        options.success(labelsInfo)
  
      options.error
      this
      retry
    )
    
  sync: (method, model, options) ->
    if method is not "read"
      super(method, model, options)
    else
      if @app? and not @app.gmailAPIReady
        setTimeout(
          =>
            @sync(method, model, options)
          100
        )

        return

      request = gapi.client.gmail.users.labels.list(userId: "me")

      google_execute_request(
        request

        (response) =>
          @loadLabels(
            response.result.labels,
            options
            => @app.refreshGmailAPIToken().done(=> @sync(method, model, options))
          )

        options.error
        this
        => @app.refreshGmailAPIToken().done(=> @sync(method, model, options))
      )


  ###############
  ### Getters ###
  ###############

  getEmailFolder: (emailFolderID) ->
    emailFolders = @filter((emailFolder) ->
      emailFolder.get("label_id") is emailFolderID
    )

    return if emailFolders.length > 0 then emailFolders[0] else null
