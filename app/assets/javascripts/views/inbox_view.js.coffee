window.InboxView = Backbone.View.extend(
    initialize: ->
        @collection.on "add", @addOne, this
        @collection.on "reset", @addAll, this
        return

    render: ->
        @addAll()
        this.renderInitialPreviewPane(@collection.first())
        this

    addAll: ->
        @$el.empty()
        @$el.append "<div class='table-responsive'><table class='table' id='email_table'><tbody id='email_table_body'>"
        @collection.forEach @addOne, this

        return

    renderInitialPreviewPane: (email) ->
        @$el.append "<div id='preview_pane'><div id='resize_border'></div><div id='preview_content'><div id='email_content'></div></div></div>"

        emailView = new EmailView(model: email)
        @$el.find("#email_content").append emailView.render().el

        console.log email

    addOne: (email) ->
        emailHeaderView = new EmailHeaderView(model: email)
        @$el.find("#email_table_body").append emailHeaderView.render().el
        return
)