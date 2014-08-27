window.EmailFoldersView = Backbone.View.extend(    
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

    addOne: (email_folder_header) ->
        emailFolderView = new EmailFolderHeaderView(model: email_folder_header)
        @$el.append emailFolderView.render().el
        return
)