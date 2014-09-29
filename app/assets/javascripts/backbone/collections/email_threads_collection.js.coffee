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
      
  modelRemoved: (model) ->
    model.trigger("removedFromCollection", this)

  modelsReset: (models, options) ->
    options.previousModels.forEach(@modelRemoved, this)

  getEmailThread: (emailThreadUID) ->
    emailThreads = @filter((emailThread) ->
      emailThread.get("uid") is emailThreadUID
    )

    return if emailThreads.length > 0 then emailThreads[0] else null

  seenIs: (emailThreadUIDs, seenValue=true) ->
    for emailThreadUID in emailThreadUIDs
      emailThread = @getEmailThread emailThreadUID
      emailThread.seenIs(seenValue)

  # TODO write tests
  previousPage: ->
    pageNumber = parseInt(@page)
    if @page > 1
      @page--
      @url = "/api/v1/email_threads/in_folder?folder_id=" + TuringEmailApp.currentFolderID + "&page=" + @page
      @fetch(
        success: (collection, response, options) =>
          TuringEmailApp.views.toolbarView.renderEmailsDisplayedCounter TuringEmailApp.currentFolderID
      )

  # TODO write tests
  nextPage: ->
    @page++
    @url = "/api/v1/email_threads/in_folder?folder_id=" + TuringEmailApp.currentFolderID + "&page=" + @page
    @fetch(
      success: (collection, response, options) =>
        TuringEmailApp.views.toolbarView.renderEmailsDisplayedCounter TuringEmailApp.currentFolderID
    )
