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

      # reenable when we have preview pane
      #success: (collection, response, options) ->
        #TuringEmailApp.emailThreadsRouter.showEmailThread(collection.models[0].get("uid")) if collection.length > 0
    )

  showDraftFolder: ->
    TuringEmailApp.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      folder_id: "DRAFT"
    )

    TuringEmailApp.emailThreads.draftIds = new TuringEmailApp.Collections.DraftsCollection()
    TuringEmailApp.emailThreads.draftIds.fetch()

    TuringEmailApp.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.DraftListView({
      el: $("#email_table_body")
      collection: TuringEmailApp.emailThreads
    })

    TuringEmailApp.emailThreads.fetch(
      reset: true

      # reenable when we have preview pane
      #success: (collection, response, options) ->
        #TuringEmailApp.emailThreadsRouter.showEmailThread(collection.models[0].get("uid")) if collection.length > 0
    )
