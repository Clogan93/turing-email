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
    @models = {}
    @views = {}
    @collections = {}
    @routers = {}

    @models.user = new TuringEmailApp.Models.User()
    @models.user.fetch()

    @models.userSettings = new TuringEmailApp.Models.UserSettings()
    @models.userSettings.fetch()

    @collections.emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
    @routers.emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()
    @views.emailFoldersTreeView = new TuringEmailApp.Views.EmailFolders.TreeView(
      el: $("#email_folders")
      collection: @collections.emailFolders
    )
    @views.toolbarView = new TuringEmailApp.Views.ToolbarView(
      el: $("#email-folder-mail-header")
      collection: @collections.emailFolders
    )
    @views.toolbarView.render()

    @collections.emailFolders.fetch(
      reset: true

      success: (collection, response, options) =>
        # Set the inbox count to the number of emails in the inbox.
        inboxFolder = TuringEmailApp.collections.emailFolders.getEmailFolder("INBOX")
        $(".inbox_count_badge").html(inboxFolder.get("num_unread_threads")) if inboxFolder?

        @views.toolbarView.renderLabelTitleAndUnreadCount "INBOX"
    )

    @views.composeView = new TuringEmailApp.Views.ComposeView(
      el: $("#modals")
    )
    @views.composeView.render()

    @routers.emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()

    windowLocationHash = window.location.hash.toString()
    if windowLocationHash.indexOf("#folder#") == -1
      @routers.emailFoldersRouter.showFolder("INBOX")

    #Routers
    @routers.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
    @routers.analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()
    @routers.settingsRouter = new TuringEmailApp.Routers.SettingsRouter()
    @routers.searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()

    @start_error_logging()    

    #@start_email_sync()

    Backbone.history.start()

  currentEmailThreadIs: (emailThread) ->
    if @currentEmailThread isnt emailThread
      @currentEmailThread = emailThread
      @trigger "currentEmailThreadChanged"

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
