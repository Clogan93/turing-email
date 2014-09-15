class TuringEmailApp.Collections.EmailThreadsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailThread
  url: "/api/v1/email_threads/inbox"

  initialize: (options) ->
    @on("remove", @hideModel)

    page = getQuerystringNameValue("page")
    @url = "/api/v1/email_threads/in_folder?folder_id=" + options.folder_id

    if page != null
      @url += "&page=" + page

  hideModel: (model) ->
    model.trigger("hide")

  getEmailThread: (emailThreadUID) ->
    emailThreads = @filter((emailThread) ->
      emailThread.get("uid") is emailThreadUID
    )

    return if emailThreads.length > 0 then emailThreads[0] else null

  setSeen: (emailThreadUIDs) ->
    for emailThreadUID in emailThreadUIDs
      emailThread = @getEmailThread emailThreadUID
      emailThread.setSeen()

  setUnseen: (emailThreadUIDs) ->
    for emailThreadUID in emailThreadUIDs
      emailThread = @getEmailThread emailThreadUID
      emailThread.setUnseen()
