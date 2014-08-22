window.EmailFolder = Backbone.Collection.extend(
    model: Email

    retrieveEmail: (id) ->
        modelToReturn = @filter((email) ->
            email.attributes.email_thread[0].id.toString() is id.toString()
        )
        return modelToReturn[0]
)