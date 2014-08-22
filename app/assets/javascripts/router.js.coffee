window.EmailApp = new (Backbone.Router.extend(
    Models: {}
    Views: {}
    Collections: {}

    routes:
        "": "index"
        "label#:id": "show_label_info"
        "email#:id": "show_email"

    initialize: ->
        #Collections
        this.Collections.inbox = new Inbox()
        this.Collections.email_folders = new EmailFolders()

        #View
        this.Views.inboxView = new InboxView(collection: this.Collections.inbox)
        this.Views.inboxView.render()
        this.Views.emailFoldersView = new EmailFoldersView(collection: this.Collections.email_folders)
        this.Views.emailFoldersView.render()
        return

    index: ->
        $("#app").html this.Views.inboxView.el
        this.Collections.inbox.fetch success: (collection, response, options) ->
            
            # Set the inbox count to the number of emails in the inbox.
            $("#inbox_count_badge").html collection.unreadCount()
            return

        $("#email_folders").html this.Views.emailFoldersView.el
        this.Collections.email_folders.fetch  success: (collection, response, options) ->
            return

        return

    start: ->
        Backbone.history.start()
        return

    show_label_info: (id) ->
        console.log "1"
        this.Collections.emailFolder = new EmailFolder()
        this.Collections.emailFolder.url = "/api/v1/email_threads/in_folder?folder_id=" + id.toString()
        this.Views.emailFolderView = new EmailFolderView(collection: this.Collections.emailFolder)
        this.Views.emailFolderView.render()
        $("#app").html this.Views.emailFolderView.el
        this.Collections.emailFolder.fetch  success: (collection, response, options) ->
            console.log collection
            return

        return

    show_email: (id) ->
        email = this.Collections.inbox.retrieveEmail id
        email = this.Collections.emailFolder.retrieveEmail id  if email is `undefined`
        this.Views.emailView = new EmailView({ model: email });
        this.Views.emailView.render()
        $("#app").html this.Views.emailView.el
        return
))()