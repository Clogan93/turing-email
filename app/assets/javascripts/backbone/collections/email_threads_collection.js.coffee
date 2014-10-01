class TuringEmailApp.Collections.EmailThreadsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailThread
  url: "/api/v1/email_threads/inbox"

  initialize: (models, options) ->
    @listenTo(this, "remove", @modelRemoved)
    @listenTo(this, "reset", @modelsReset)

    @setupURL(options?.folderID, options?.page)

  # TODO write tests
  setupURL: (folderID, page) ->
    @url = "/api/v1/email_threads/in_folder?folder_id=" + folderID if folderID
    
    if page
      @page = parseInt(page)
      @url += "&page=" + @page
    else
      @page = 1
      
  modelRemoved: (model) ->
    model.trigger("removedFromCollection", this)

  modelsReset: (models, options) ->
    options.previousModels.forEach(@modelRemoved, this)

  getEmailThread: (emailThreadUID) ->
    emailThreads = @filter((emailThread) ->
      emailThread.get("uid") is emailThreadUID
    )

    return if emailThreads.length > 0 then emailThreads[0] else null

  # TODO write tests
  previousPage: (success) ->
    pageNumber = parseInt(@page)
    if @page > 1
      @page--
      @setupURL(TuringEmailApp.selectedEmailFolder().get("label_id"), @page)
      @fetch(success: success)

  # TODO write tests
  nextPage: (success) ->
    @page++
    @setupURL(TuringEmailApp.selectedEmailFolder().get("label_id"), @page)
    @fetch(success: success)
