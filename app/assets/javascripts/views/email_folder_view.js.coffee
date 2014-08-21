window.EmailFolderView = Backbone.View.extend(
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
        console.log email
        emailHeaderView = new EmailHeaderView(model: email)
        @$el.append emailHeaderView.render().el
        return
)