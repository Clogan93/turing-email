class TuringEmailApp.Collections.EmailThreadsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailThread
  url: "/api/v1/email_threads/inbox"

  initialize: (options) ->
    @on "remove", @hideModel, this
    page = getQuerystringNameValue("page")

    if (options?.url?)
      @url = options.url
    else if page != null
      @url = "/api/v1/email_threads/inbox?page=" + page

  hideModel: (model) ->
    model.trigger "hide"

  retrieveEmail: (uid) ->
    modelToReturn = @filter((thread) ->
      email = thread.get("emails")[0]
      email.uid is uid
    )
    return modelToReturn[0]

  unreadCount: ->
    modelToCount = @filter((thread) ->
      email = thread.get("emails")[0]
      email.seen is false
    )
    return modelToCount.length
