class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  routes:
    "inbox": "showInbox"
    "folder/:folder_id": "showFolder"

  showInbox: ->
    @showFolder "INBOX"

  showFolder: (folderID) ->
    TuringEmailApp.currentEmailFolderIs(folderID)
