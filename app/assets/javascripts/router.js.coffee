window.EmailApp = new (Backbone.Router.extend(
    Models: {}
    Views: {}
    Collections: {}

    routes:
        "": "index"
        "label#:id": "show_label_info"
        "email#:id": "show"

    initialize: ->
        #Collections
        this.Collections.inbox = new Inbox()

        #View
        this.Views.inboxView = new InboxView(collection: this.Collections.inbox)
        this.Views.inboxView.render()
        return

    index: ->
        $("#app").html this.Views.inboxView.el
        this.Collections.inbox.fetch success: (collection, response, options) ->
            
            # Set the inbox count to the number of emails in the inbox. 
            $("#inbox_count_badge").html collection.length
            return

        return

    start: ->
        Backbone.history.start()
        return

    show_label_info: (id) ->
        $("#app").html "<div>Here will be the emails for label " + id + ".</div>"
        return

    show: (id) ->
        $(".email_body").show()
        $(".email_information_header").hide()

        this.Collections.inbox.focusOnEmail id
        return
))()