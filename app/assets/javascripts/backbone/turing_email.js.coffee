#= require_self
#= require_tree ./templates
#= require ./models/email
#= require_tree ./models
#= require_tree ./collections
#= require ./views/email_threads/list_item_view
#= require ./views/email_threads/list_view
#= require_tree ./views
#= require_tree ./routers

originalBackboneSync = Backbone.sync

Backbone.sync = (method, model, options) ->
  options = {} if not options
  error = options.error if options.error?
  
  options.error = (model, response, options) ->
    error(model, response, options) if error?
    
    TuringEmailApp.tattletale.log(response)
    TuringEmailApp.tattletale.send()

  originalBackboneSync(method, model, options)
  
window.TuringEmailApp = new(Backbone.View.extend({
  Models: {}
  Views: {}
  Collections: {}
  Routers: {}

  start: ->
    @user = new TuringEmailApp.Models.User()
    @user.fetch()

    @userSettings = new TuringEmailApp.Models.UserSettings()
    @userSettings.fetch()

    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
    @emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()
    @emailFoldersTreeView = new TuringEmailApp.Views.EmailFolders.TreeView(
      el: $("#email_folders")
      collection: @emailFolders
    )
    @toolbarView = new TuringEmailApp.Views.ToolbarView(
      el: $("#email-folder-mail-header")
      collection: @emailFolders
    )
    @toolbarView.render()

    @emailFolders.fetch(
      reset: true

      success: (collection, response, options) =>
        # Set the inbox count to the number of emails in the inbox.
        inboxFolder = TuringEmailApp.emailFolders.getEmailFolder("INBOX")
        $(".inbox_count_badge").html(inboxFolder.get("num_unread_threads")) if inboxFolder?

        @toolbarView.renderLabelTitleAndUnreadCount "INBOX"
    )

    @emailDraftIDs = new TuringEmailApp.Collections.EmailDraftIDsCollection()

    @composeView = new TuringEmailApp.Views.ComposeView(
      el: $("#modals")
    )
    @composeView.render()

    @emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()

    windowLocationHash = window.location.hash.toString()
    if windowLocationHash.indexOf("#folder#") == -1
      @emailFoldersRouter.showFolder("INBOX")

    #Routers
    @reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
    @analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()
    @settingsRouter = new TuringEmailApp.Routers.SettingsRouter()
    @searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()

    @start_error_logging()    

    #@start_email_sync()

    Backbone.history.start()

  start_error_logging: ->
    @tattletale = new Tattletale('/api/v1/log.json')

    window.onerror = (message, url, lineNumber, column, errorObj) ->      
      #save error and send to server for example.
      TuringEmailApp.tattletale.log(JSON.stringify(message))
      TuringEmailApp.tattletale.log(JSON.stringify(url.toString()))
      TuringEmailApp.tattletale.log(JSON.stringify("Line number: " + lineNumber.toString()))

      if errorObj?
        TuringEmailApp.tattletale.log(JSON.stringify(errorObj.stack))

      TuringEmailApp.tattletale.send()
      false

  start_email_sync: ->
    window.setInterval (->
      $.ajax({
        url: 'api/v1/email_accounts/sync.json'
        type: 'POST'
        dataType : 'json'
        }).done((data, status) =>
          if data.synced_emails
            TuringEmailApp.emailThreads.fetch()
        ).fail (data, status) ->
          TuringEmailApp.tattletale.log(JSON.stringify(status))
          TuringEmailApp.tattletale.log(JSON.stringify(data))
          TuringEmailApp.tattletale.send()
    #/ call your function here
    ), 60000

  #################################################################
  ########################### Re-styling ##########################
  #################################################################
  
  #TODO: re-factor mail.html.erb so that this is not longer necessary.
  restyle_other_elements: ->
    $("#preview_panel").hide()
    $(".mail-box-header").hide()
    $("table.table-mail").hide()
    $("#pages").hide()
    $("#email_table").hide()
    $("#preview_pane").hide()
    $(".main_email_list_content").css("height", "100%")
    
}))({el: document.body})
