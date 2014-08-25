window.EmailApp = new (Backbone.Router.extend(
    Models: {}
    Views: {}
    Collections: {}

    routes:
        "": "index"
        "label#:id": "show_label_info"
        "email#:uid": "show_email"

    initialize: ->
        #Models
        this.Models.user = new User()

        #Collections
        this.Collections.inbox = new Inbox()
        this.Collections.email_folders = new EmailFolders()

        #View
        this.Views.inboxView = new InboxView(collection: this.Collections.inbox)
        this.Views.emailFoldersView = new EmailFoldersTreeView(collection: this.Collections.email_folders)
        return

    index: ->
        $("#app").html this.Views.inboxView.el
        this.Collections.inbox.fetch success: (collection, response, options) ->
            
            EmailApp.Views.inboxView.render()

            # Set the inbox count to the number of emails in the inbox.
            $("#inbox_count_badge").html collection.unreadCount()

            return

        $("#email_folders").html this.Views.emailFoldersView.el
        this.Collections.email_folders.fetch  success: (collection, response, options) ->
            EmailApp.Views.emailFoldersView.render()

            $(".bullet_span").click ->
                $(this).parent().children("ul").children("li").toggle()

            return

        this.Models.user.fetch  success: (model, response, options) ->
            return

        return

    start: ->
        Backbone.history.start()
        return

    show_label_info: (id) ->
        this.Collections.emailFolder = new EmailFolder()
        this.Collections.emailFolder.url = "/api/v1/email_threads/in_folder?folder_id=" + id.toString()
        this.Views.emailFolderView = new EmailFolderView(collection: this.Collections.emailFolder)
        this.Views.emailFolderView.render()
        $("#app").html this.Views.emailFolderView.el
        this.Collections.emailFolder.fetch  success: (collection, response, options) ->
            return

        return

    show_email: (uid) ->
        email = this.Collections.inbox.retrieveEmail uid
        email = this.Collections.emailFolder.retrieveEmail uid  if email is `undefined`
        this.Views.emailView = new EmailView({ model: email });
        this.Views.emailView.render()
        $("#app").find("#email_content").html this.Views.emailView.el

        $(".email").click ->
            $(this).find(".email_body").show()
            $(this).removeClass("collapsed_email")
            console.log $(this).siblings(".email").each ->
                $(this).addClass "collapsed_email"
                $(this).find(".email_body").hide()

        return
))()