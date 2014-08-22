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
        @$el.append "<div class='table-responsive'><table class='table' id='email_table'><tbody id='email_table_body'>"
        @collection.forEach @addOne, this
        return

    addOne: (email) ->
        emailHeaderView = new EmailHeaderView(model: email)
        @$el.find("#email_table_body").append emailHeaderView.render().el
        return
)