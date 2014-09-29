class TuringEmailApp.Collections.EmailThreadsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailThread
  url: "/api/v1/email_threads/inbox"

  initialize: (models, options) ->
    @listenTo(this, "remove", @modelRemoved)
    @listenTo(this, "reset", @modelsReset)

    @setupURL(options?.folderID)

  setupURL: (folderID) ->
    @url = "/api/v1/email_threads/in_folder?folder_id=" + folderID if folderID

    page = getQuerystringNameValue("page")
    @page = if page? then parseIn(page) else 1
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

  previousPage: ->
    pageNumber = parseInt(@page)
    if @page > 1
      @page--
      @url = "/api/v1/email_threads/in_folder?folder_id=" + TuringEmailApp.currentFolderID + "&page=" + @page
      @fetch(
        success: (collection, response, options) =>
          TuringEmailApp.views.toolbarView.renderEmailsDisplayedCounter TuringEmailApp.currentFolderID
      )

  nextPage: ->
    @page++
    @url = "/api/v1/email_threads/in_folder?folder_id=" + TuringEmailApp.currentFolderID + "&page=" + @page
    @fetch(
      success: (collection, response, options) =>
        TuringEmailApp.views.toolbarView.renderEmailsDisplayedCounter TuringEmailApp.currentFolderID
    )
