class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  routes:
    "folder#:folder_id": "show_folder"

  show_folder: (folder_id) ->
    url = "/api/v1/email_threads/in_folder?folder_id=" + folder_id
    TuringEmailApp.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      url: url
    )

    TuringEmailApp.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView({
      el: $("#emails_threads_list_view")
      collection: TuringEmailApp.emailThreads
    })

    TuringEmailApp.emailThreads.fetch(
      success: (collection, response, options) ->
        TuringEmailApp.emailThreadsListView.render()
    )
