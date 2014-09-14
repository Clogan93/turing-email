#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

window.TuringEmailApp = new(Backbone.View.extend({
  Models: {}
  Views: {}
  Collections: {}
  Routers: {}

  start: ->
    @user = new TuringEmailApp.Models.User()
    @user.fetch()

    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
    @emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()
    @emailFoldersTreeView = new TuringEmailApp.Views.EmailFolders.TreeView(
      el: $("#email_folders")
      collection: @emailFolders
    )

    @emailFolders.fetch(
      reset: true

      success: (collection, response, options) ->
        # Set the inbox count to the number of emails in the inbox.
        inboxFolder = TuringEmailApp.emailFolders.getEmailFolder("INBOX")
        $(".inbox_count_badge").html(inboxFolder.get("num_unread_threads")) if inboxFolder?

        @toolbarView = new TuringEmailApp.Views.ToolbarView(
          el: $("#email-folder-mail-header")
          collection: collection
        )
        @toolbarView.render()
    )

    @emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()

    windowLocationHash = window.location.hash.toString()
    if windowLocationHash == "" 
      @emailFoldersRouter.showFolder("INBOX")

    @reportsRouter = new TuringEmailApp.Routers.ReportsRouter()

    @analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()

    @settingsRouter = new TuringEmailApp.Routers.SettingsRouter()

    Backbone.history.start()
}))({el: document.body})
