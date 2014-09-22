class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  routes:
    "folder#DRAFT": "showDraftFolder"
    "folder#:folder_id": "showFolder"
    "inbox": "showInboxFolder"

  showInboxFolder: ->
    @showFolder "INBOX"

  showFolder: (folder_id) ->
    TuringEmailApp.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      folder_id: folder_id
    )

    TuringEmailApp.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView({
      el: $("#email_table_body")
      collection: TuringEmailApp.emailThreads
    })

    TuringEmailApp.emailThreads.fetch(
      reset: true
    )

    TuringEmailApp.currentFolderId = folder_id
    TuringEmailApp.toolbarView.renderLabelTitleAndUnreadCount folder_id

  showDraftFolder: ->
    TuringEmailApp.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      folder_id: "DRAFT"
    )

    TuringEmailApp.emailDraftIDs.fetch()

    TuringEmailApp.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.DraftListView({
      el: $("#email_table_body")
      collection: TuringEmailApp.emailThreads
    })

    TuringEmailApp.emailThreads.fetch(
      reset: true
      success: (collection, response, options) ->
        TuringEmailApp.emailThreadsListView.setupDraftComposeView()
    )

    TuringEmailApp.currentFolderId = "DRAFT"
    TuringEmailApp.toolbarView.renderLabelTitleAndUnreadCount "DRAFT"
