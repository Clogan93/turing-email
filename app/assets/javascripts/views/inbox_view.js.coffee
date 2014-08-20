window.InboxView = Backbone.View.extend(
    initialize: ->
        @collection.on "add", @addOne, this
        @collection.on "reset", @addAll, this
        return

    render: ->
        @addAll()
        this

    addAll: ->
        @$el.empty()
        @collection.forEach @addOne, this
        return

    addOne: (email) ->
        emailView = new EmailView(model: email)
        @$el.append emailView.render().el
        return
)