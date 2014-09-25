class TuringEmailApp.Routers.EmailFoldersRouter extends Backbone.Router
  routes:
    "inbox": "showInbox"
    "email_folder/:emailFolderID": "showFolder"

  showInbox: ->
    @showFolder "INBOX"

  showFolder: (emailFolderID) ->
    TuringEmailApp.currentEmailFolderIs(emailFolderID)
