class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  initialize: (options) ->
    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
    @emailFolders.reset options.emailFolders

  routes:
    "email_folders"       : "index"
    "email_folders#:id"   : "show"
    "email_folders#.*"                  : "index"

  index: ->
    @view = new TuringEmailApp.Views.EmailFolders.IndexView(collection: @email_folders)
    $("#email_folders").html(@view.render().el)
    
  show: (id) ->
    email_folder = @email_folders.get(id)

    @view = new TuringEmailApp.Views.EmailFolders.ShowView(model: email_folder)
    $("#email_folders").html(@view.render().el)
