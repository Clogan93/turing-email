class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  routes:
    "folder#:folder_id": "showFolder"
    "inbox": "showInboxFolder"

  showInboxFolder: ->
    @showFolder "INBOX"

  showFolder: (folderID) ->
    TuringEmailApp.currentEmailFolderIs(folderID)
