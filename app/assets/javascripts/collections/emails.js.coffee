window.Emails = Backbone.Collection.extend(
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
            email.attributes.thread[0].id isnt id
        )
        @remove modelsToRemove
        return
)