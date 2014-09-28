#= require_self
#= require_tree ./templates
#= require ./models/email
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
    @trigger("change:toolbarView", this, @views.toolbarView)

    @collections.emailFolders.fetch(
      reset: true

      success: (collection, response, options) =>
        # Set the inbox count to the number of emails in the inbox.
        inboxFolder = TuringEmailApp.collections.emailFolders.getEmailFolder("INBOX")
        numUnreadThreadsInInbox = inboxFolder.get("num_unread_threads")
        if numUnreadThreadsInInbox is 0
          $(".inbox_count_badge").hide()
        else  
          $(".inbox_count_badge").html(numUnreadThreadsInInbox) if inboxFolder?

        @views.toolbarView.renderLabelTitleAndUnreadCount "INBOX"
        @views.toolbarView.renderEmailsDisplayedCounter "INBOX"
    )

    @views.composeView = new TuringEmailApp.Views.ComposeView(
      el: $("#modals")
    )
    @listenTo(@views.composeView, "change:draft", @draftChanged)
    @views.composeView.render()

    @routers.emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()

    windowLocationHash = window.location.hash.toString()
    if windowLocationHash.indexOf("#email_folder/") == -1
      @routers.emailFoldersRouter.showFolder("INBOX")

    #Routers
    @routers.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
    @routers.analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()
    @routers.settingsRouter = new TuringEmailApp.Routers.SettingsRouter()
    @routers.searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()    

    #@startEmailSync()

    Backbone.history.start()

  isSplitPaneMode: ->
    splitPaneMode = TuringEmailApp.models.userSettings.get("split_pane_mode")
    return splitPaneMode is "horizontal" || splitPaneMode is "vertical"
  
  loadEmailThread:(emailThreadUID, callback) ->
    emailThread = TuringEmailApp.collections.emailThreads?.getEmailThread(emailThreadUID)

    if emailThread?
      callback(emailThread)
    else
      emailThread = new TuringEmailApp.Models.EmailThread(undefined, emailThreadUID: emailThreadUID)
      emailThread.fetch(
        success: (model, response, options) =>
          callback?(emailThread)
      )
      
  currentEmailThreadIs: (emailThreadUID, forceReload = false) ->
    return if not forceReload && @currentEmailThread?.get("uid") is emailThreadUID 
    
    TuringEmailApp.loadEmailThread(emailThreadUID, (emailThread) =>
      return if @currentEmailThread is emailThread
      
      @currentEmailThread = emailThread

      if TuringEmailApp.isSplitPaneMode()
        $("#preview_panel").show()
        emailThreadViewSelector = "#preview_content"
      else
        emailThreadViewSelector = "#email_table_body"
        $("#email-folder-mail-header").hide()

      emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
        model: TuringEmailApp.currentEmailThread
        el: $(emailThreadViewSelector)
      )
      emailThreadView.render()

      TuringEmailApp.views.previewEmailThreadView = emailThreadView if TuringEmailApp.isSplitPaneMode()

      @trigger "change:currentEmailThread", this, emailThread
    )

  showEmailEditorWithEmailThread:(emailThreadUID, mode="draft") ->
    callback = (emailThread) =>
      TuringEmailApp.currentEmailThreadIs emailThread.get("uid")

      switch mode
        when "forward"
          TuringEmailApp.views.composeView.loadEmailAsForward(emailThread.get("emails")[0])
        when "reply"
          TuringEmailApp.views.composeView.loadEmailAsReply(emailThread.get("emails")[0])
        else
          TuringEmailApp.views.composeView.loadEmailDraft emailThread.get("emails")[0]
      
      TuringEmailApp.views.composeView.show()

    TuringEmailApp.loadEmailThread(emailThreadUID, callback)

  currentEmailFolderIs: (emailFolderID) ->
    if not TuringEmailApp.collections.emailThreads
      TuringEmailApp.collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
        folderID: emailFolderID
      )
    else
      TuringEmailApp.collections.emailThreads.setupURL(emailFolderID)

    if not TuringEmailApp.views.emailThreadsListView?
      TuringEmailApp.views.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView({
        el: $("#email_table_body")
        collection: TuringEmailApp.collections.emailThreads
      })

    TuringEmailApp.collections.emailThreads.fetch(
      reset: true
      success: (collection, response, options) ->
        if TuringEmailApp.isSplitPaneMode() && TuringEmailApp.collections.emailThreads.length > 0
          TuringEmailApp.currentEmailThreadIs(TuringEmailApp.collections.emailThreads.models[0].get("uid"))
    )

    TuringEmailApp.views.emailFoldersTreeView.currentEmailFolderIs emailFolderID
    TuringEmailApp.currentFolderId = emailFolderID
    TuringEmailApp.views.toolbarView.renderLabelTitleAndUnreadCount emailFolderID
    TuringEmailApp.views.toolbarView.renderEmailsDisplayedCounter emailFolderID
    TuringEmailApp.showEmails()
    
  draftChanged: ->
    @collections.emailThreads.fetch(reset: true) if TuringEmailApp.currentFolderId is "DRAFT"

  startEmailSync: ->
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

  showEmails: ->
    @hideAll()
    
    $("#preview_panel").show()
    $(".mail-box-header").show()
    $("table.table-mail").show()
    $("#pages").show()
    $("#email_table").show()
    
  hideEmails: ->
    $("#preview_panel").hide()
    $(".mail-box-header").hide()
    $("table.table-mail").hide()
    $("#pages").hide()
    $("#email_table").hide()
    
  showSettings: ->
    @hideAll()

    $("#settings").show()
    $(".main_email_list_content").css("height", "100%")

  hideSettings: ->
    $("#settings").hide()
    
  showReports: ->
    @hideAll()

    $("#reports").show()
    $("#settings").hide()
    $(".main_email_list_content").css("height", "100%")
    
  hideReports: ->
    $("#reports").hide()

  hideAll: ->
    @hideEmails()
    @hideReports()
    @hideSettings()

}))({el: document.body})

TuringEmailApp.tattletale = new Tattletale('/api/v1/log.json')

$(document).ajaxError((event, jqXHR, ajaxSettings, thrownError) ->
  TuringEmailApp.tattletale.log(JSON.stringify(jqXHR))
  TuringEmailApp.tattletale.send()
)

window.onerror = (message, url, lineNumber, column, errorObj) ->
  #save error and send to server for example.
  TuringEmailApp.tattletale.log(JSON.stringify(message))
  TuringEmailApp.tattletale.log(JSON.stringify(url.toString()))
  TuringEmailApp.tattletale.log(JSON.stringify("Line number: " + lineNumber.toString()))

  if errorObj?
    TuringEmailApp.tattletale.log(JSON.stringify(errorObj.stack))

  TuringEmailApp.tattletale.send()
  return false
