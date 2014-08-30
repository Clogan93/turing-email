class TuringEmailApp.Collections.EmailThreadsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailThread
  url: "/api/v1/email_threads/inbox"

  initialize: (options) ->
    @on("remove", @hideModel)

    page = getQuerystringNameValue("page")

    if (options?.url?)
      @url = options.url
    else if page != null
      @url = "/api/v1/email_threads/inbox?page=" + page

  hideModel: (model) ->
    model.trigger("hide")

  getEmailThread: (emailThreadUID) ->
    emailThreads = @filter((emailThread) ->
      emailThread.get("uid") is emailThreadUID
    )

    return if emailThreads.length > 0 then emailThreads[0] else null
