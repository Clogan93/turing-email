window.EmailApp = new (Backbone.Router.extend(
    routes:
        "": "index"
        "label#:id": "test"
        "email#:id": "show"

    initialize: ->
        console.log "1"
        @emails = new Emails()
        console.log "2"
        @inboxView = new InboxView(collection: @emails)
        @inboxView.render()
        console.log "3"
        return

    index: ->
        console.log "4"
        $("#app").html @inboxView.el
        @emails.fetch success: (collection, response, options) ->
            
            # Set the inbox count to the number of emails in the inbox. 
            $("#inbox_count_badge").html collection.length
            return

        return

    start: ->
        Backbone.history.start()
        return

    test: (id) ->
        console.log id
        $("#app").html "<div>Here will be the emails for label " + id + ".</div>"
        return

    show: (id) ->
        $(".email_body").show()
        $(".email_information_header").hide()
        $(".email_preview_text").hide()
        $(".reply_button").click ->
            $("#dialog").dialog "open"
            return

        $(".forward_button").click ->
            $("#dialog").dialog "open"
            return

        @emails.focusOnEmail id
        return
))()