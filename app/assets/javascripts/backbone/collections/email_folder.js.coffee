window.EmailFolder = Backbone.Collection.extend(
    model: Email

    retrieveEmail: (uid) ->
        modelToReturn = @filter((email) ->
            email.attributes.email_thread.emails[0].email.uid.toString() is uid.toString()
        )
        return modelToReturn[0]

    unreadCount: ->
        modelToCount = @filter((email) ->
            email.attributes.thread[0].seen is false
        )
        return modelToCount.length
)