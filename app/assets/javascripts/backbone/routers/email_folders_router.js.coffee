class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  routes:
    "email_folder/:emailFolderID": "showFolder"
    "email_folder/:emailFolderID/:page": "showFolderPage"

  showFolder: (emailFolderID) ->
    TuringEmailApp.currentEmailFolderIs(emailFolderID)

  showFolderPage: (emailFolderID, pageTokenIndex) ->
    TuringEmailApp.currentEmailFolderIs(emailFolderID, pageTokenIndex)
