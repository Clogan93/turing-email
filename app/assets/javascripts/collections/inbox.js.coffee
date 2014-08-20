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
            email.id isnt id
        )
        @remove modelsToRemove
        return
)