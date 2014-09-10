class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  routes:
    "folder#:folder_id": "showFolder"

  showFolder: (folder_id, useDefaultURL = false) ->
    url = if useDefaultURL then undefined else "/api/v1/email_threads/in_folder?folder_id=" + folder_id
    TuringEmailApp.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      url: url
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
