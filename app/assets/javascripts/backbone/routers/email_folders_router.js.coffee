class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  routes:
    "folder#DRAFT": "showDraftFolder"
    "folder#:folder_id": "showFolder"

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

  showDraftFolder: ->
    TuringEmailApp.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      folder_id: "DRAFT"
    )

    TuringEmailApp.emailThreads.drafts = new TuringEmailApp.Collections.DraftsCollection()
    TuringEmailApp.emailThreads.drafts.fetch()

    TuringEmailApp.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.DraftListView({
      el: $("#email_table_body")
      collection: TuringEmailApp.emailThreads
    })

    TuringEmailApp.emailThreads.fetch(
      reset: true
    )
