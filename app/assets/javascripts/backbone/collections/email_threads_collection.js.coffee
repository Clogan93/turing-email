class TuringEmailApp.Collections.EmailThreadsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailThread
  url: "/api/v1/email_threads/inbox"

  initialize: (options) ->
    @on("remove", @hideModel)

    @page = getQuerystringNameValue("page")
    @url = "/api/v1/email_threads/in_folder?folder_id=" + options.folder_id

    if @page != null
      @url += "&page=" + @page
    else
      @page = "1"

  hideModel: (model) ->
    model.trigger("hide")

  getEmailThread: (emailThreadUID) ->
    emailThreads = @filter((emailThread) ->
      emailThread.get("uid") is emailThreadUID
    )

    return if emailThreads.length > 0 then emailThreads[0] else null

  seenIs: (emailThreadUIDs, seenValue=true) ->
    for emailThreadUID in emailThreadUIDs
      emailThread = @getEmailThread emailThreadUID
      emailThread.seenIs(seenValue)

  fetchPreviousPage: ->
    page_number = parseInt(@page)
    if page_number > 1
      @page = (page_number - 1).toString()
      @url = "/api/v1/email_threads/in_folder?folder_id=" + TuringEmailApp.currentFolderId + "&page=" + @page
      @fetch(
        success: (collection, response, options) =>
          TuringEmailApp.emailThreadsListView.renderCheckboxes()
      )

  fetchNextPage: ->
    @page = (parseInt(@page) + 1).toString()
    @url = "/api/v1/email_threads/in_folder?folder_id=" + TuringEmailApp.currentFolderId + "&page=" + @page
    @fetch(
      success: (collection, response, options) =>
        TuringEmailApp.emailThreadsListView.renderCheckboxes()
    )
