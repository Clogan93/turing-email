class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  routes:
    "label#:id": "show_folder"

  show_folder: (folder_id) ->
    url = "/api/v1/email_threads/in_folder?folder_id=" + folder_id
    console.log url
    TuringEmailApp.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      url: url
    )

    TuringEmailApp.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView({
      el: $("#app")
      collection: TuringEmailApp.emailThreads
    })

    TuringEmailApp.emailThreads.fetch(
      success: (collection, response, options) ->
        TuringEmailApp.emailThreadsListView.render()
    )
