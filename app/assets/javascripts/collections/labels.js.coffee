window.Labels = Backbone.Collection.extend(
    model: Label
    url: "/labels"
    initialize: ->
        @on "remove", @hideModel, this
        return

    hideModel: (model) ->
        model.trigger "hide"
        return
)