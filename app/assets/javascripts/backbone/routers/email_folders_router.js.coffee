class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  routes:
    "folder#DRAFT": "showDraftFolder"
    "folder#:folder_id": "showFolder"
    "inbox": "showInboxFolder"

  showInboxFolder: ->
    @showFolder "INBOX"

  showFolder: (folder_id) ->
    TuringEmailApp.collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      folder_id: folder_id
    )

    TuringEmailApp.views.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView({
      el: $("#email_table_body")
      collection: TuringEmailApp.collections.emailThreads
    })

    TuringEmailApp.collections.emailThreads.fetch(
      reset: true
    )

    TuringEmailApp.currentFolderId = folder_id
    TuringEmailApp.views.toolbarView.renderLabelTitleAndUnreadCount folder_id

  showDraftFolder: ->
    TuringEmailApp.collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      folder_id: "DRAFT"
    )

    TuringEmailApp.collections.emailDraftIDs.fetch()

    TuringEmailApp.views.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.DraftListView({
      el: $("#email_table_body")
      collection: TuringEmailApp.collections.emailThreads
    })

    TuringEmailApp.collections.emailThreads.fetch(
      reset: true
      success: (collection, response, options) ->
        TuringEmailApp.views.emailThreadsListView.setupDraftComposeView()
    )

    TuringEmailApp.currentFolderId = "DRAFT"
    TuringEmailApp.views.toolbarView.renderLabelTitleAndUnreadCount "DRAFT"
