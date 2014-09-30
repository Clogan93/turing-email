class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  routes:
    "email_folder/:emailFolderID": "showFolder"

  showFolder: (emailFolderID) ->
    TuringEmailApp.currentEmailFolderIs(emailFolderID)
