window.Inbox = Backbone.Collection.extend(
    model: Email
    url: "/emails"
    initialize: ->
        @on "remove", @hideModel, this
        return

    hideModel: (model) ->
        model.trigger "hide"
        return

    focusOnEmail: (id) ->
        modelsToRemove = @filter((email) ->
            email.attributes.thread[0].id.toString() isnt id.toString()
        )
        @remove modelsToRemove
        return

    retrieveEmail: (id) ->
        modelToReturn = @filter((email) ->
            email.attributes.thread[0].id.toString() is id.toString()
        )
        return modelToReturn[0]

    unreadCount: ->
        modelToCount = @filter((email) ->
            email.attributes.thread[0].seen is false
        )
        return modelToCount.length
)