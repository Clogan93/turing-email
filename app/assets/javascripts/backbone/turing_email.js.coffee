#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require ./views/email_threads/list_item_view
#= require ./views/email_threads/list_view
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
    if windowLocationHash.indexOf("#folder#") == -1
      @emailFoldersRouter.showFolder("INBOX")

    @reportsRouter = new TuringEmailApp.Routers.ReportsRouter()

    @analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()

    @settingsRouter = new TuringEmailApp.Routers.SettingsRouter()

    @searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()

    @userSettings = new TuringEmailApp.Models.UserSettings()
    @userSettings.fetch()

    @start_email_sync()

    Backbone.history.start()

  start_email_sync: ->
    window.setInterval (->
      console.log "Email sync called"
      $.ajax({
        url: 'api/v1/email_accounts/sync.json'
        type: 'POST'
        dataType : 'json'
        }).done((data, status) =>
          if data.synced_emails
            TuringEmailApp.emailThreads.fetch()
        )
    #/ call your function here
    ), 60000

}))({el: document.body})
