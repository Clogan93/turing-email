window.Inbox = Backbone.Collection.extend(
    model: Email
    url: "/api/v1/email_threads/inbox"
    initialize: ->
        @on "remove", @hideModel, this
        return

    hideModel: (model) ->
        model.trigger "hide"
        return

    focusOnEmail: (id) ->
        modelsToRemove = @filter((email) ->
            email.attributes.email_thread[0].id.toString() isnt id.toString()
        )
        @remove modelsToRemove
        return

    retrieveEmail: (id) ->
        modelToReturn = @filter((email) ->
            email.attributes.email_thread[0].id.toString() is id.toString()
        )
        return modelToReturn[0]
)