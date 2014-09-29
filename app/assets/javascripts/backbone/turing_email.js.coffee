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

    @setupToolbar()
    @setupUser()

    # email folders
    @setupEmailFolders()
    @loadEmailFolders()

    @setupComposeView()
    @setupEmailThreads()
    @setupRouters()

    windowLocationHash = window.location.hash.toString()
    if windowLocationHash.indexOf("#email_folder/") == -1
      @routers.emailFoldersRouter.showFolder("INBOX")

    #@startEmailSync()

    Backbone.history.start()

  startEmailSync: ->
    window.setInterval (->
      $.post("api/v1/email_accounts/sync").done((data, status) =>
        if data.synced_emails
          TuringEmailApp.emailThreads.fetch()
      )
    ), 60000
    
  setupToolbar: ->
    @views.toolbarView = new TuringEmailApp.Views.ToolbarView(
      app: this
      el: $("#email-folder-mail-header")
    )
    
    @views.toolbarView.render()
    @trigger("change:toolbarView", this, @views.toolbarView)
  
  setupUser: ->
    @models.user = new TuringEmailApp.Models.User()
    @models.user.fetch()

    @models.userSettings = new TuringEmailApp.Models.UserSettings()
    @models.userSettings.fetch()
    
  setupEmailFolders: ->
    @collections.emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
    @views.emailFoldersTreeView = new TuringEmailApp.Views.EmailFolders.TreeView(
      app: this
      el: $("#email_folders")
      collection: @collections.emailFolders
    )
    
  setupComposeView: ->
    @views.composeView = new TuringEmailApp.Views.ComposeView(
      el: $("#modals")
    )
    @listenTo(@views.composeView, "change:draft", @draftChanged)
    @views.composeView.render()
    
  setupEmailThreads: ->
    @collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()
    @views.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView({
      app: this
      el: $("#email_table_body")
      collection: TuringEmailApp.collections.emailThreads
    })

  setupRouters: ->
    @routers.emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()
    @routers.emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()
    @routers.analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()
    @routers.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
    @routers.settingsRouter = new TuringEmailApp.Routers.SettingsRouter()
    @routers.searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()
    
  isSplitPaneMode: ->
    splitPaneMode = TuringEmailApp.models.userSettings.get("split_pane_mode")
    return splitPaneMode is "horizontal" || splitPaneMode is "vertical"
    
  loadEmailFolders: ->
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
        @trigger("change:emailFolders", this)
    )
    
  showEmailThread: (emailThread) ->
    @currentEmailThread = emailThread

    if TuringEmailApp.isSplitPaneMode()
      $("#preview_panel").show()
      emailThreadViewSelector = "#preview_content"
    else
      emailThreadViewSelector = "#email_table_body"
      $("#email-folder-mail-header").hide()

    emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: @currentEmailThread
      el: $(emailThreadViewSelector)
    )
    emailThreadView.render()

    @listenTo(emailThreadView, "goBack", @goBack)
    @listenTo(emailThreadView, "replyClicked", @replyClicked)
    @listenTo(emailThreadView, "forwardClicked", @forwardClicked)
    @listenTo(emailThreadView, "archiveClicked", @archiveClicked)
    @listenTo(emailThreadView, "trashClicked", @trashClicked)

    if @currentEmailThreadView?
      @stopListening(@currentEmailThreadView)
      @currentEmailThreadView.stopListening()
      
    @currentEmailThreadView = emailThreadView
    
  loadEmailThread: (emailThreadUID, callback) ->
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
    
    if emailThreadUID
      TuringEmailApp.loadEmailThread(emailThreadUID, (emailThread) =>
        return if @currentEmailThread is emailThread
        
        @showEmailThread(emailThread)
        @trigger "change:currentEmailThread", this, emailThread
      )
    else
      @showEmailThread()
      @trigger "change:currentEmailThread", this, null

  currentEmailFolderIs: (emailFolderID) ->
    TuringEmailApp.collections.emailThreads.setupURL(emailFolderID)

    TuringEmailApp.collections.emailThreads.fetch(
      reset: true
      success: (collection, response, options) ->
        if TuringEmailApp.isSplitPaneMode() && TuringEmailApp.collections.emailThreads.length > 0
          TuringEmailApp.currentEmailThreadIs(TuringEmailApp.collections.emailThreads.models[0].get("uid"))
    )

    TuringEmailApp.currentFolderID = emailFolderID
    @trigger "change:currentEmailFolder", this, emailFolderID

    TuringEmailApp.showEmails()

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

  ##############################
  ### ComposeView events ###
  ##############################
    
  draftChanged: ->
    @collections.emailThreads.fetch(reset: true) if TuringEmailApp.currentFolderID is "DRAFT"

  ##############################
  ### EmailThreadView events ###
  ##############################
  
  goBack: ->
    @routers.emailFoldersRouter.showFolder(TuringEmailApp.currentFolderID)

  replyClicked: ->
    @showEmailEditorWithEmailThread(@currentEmailThread.get("uid"), "reply")
  
  forwardClicked: ->
    @showEmailEditorWithEmailThread(TuringEmailApp.currentEmailThread.get("uid"), "forward")
    
  archiveClicked: ->
    @currentEmailThread.removeFromFolder(@currentFolderID)
    @collections.emailThreads.remove @currentEmailThread

    if @isSplitPaneMode() then @currentEmailThreadIs(null) else @goBack()
    
  trashClicked: ->
    @currentEmailThread.trash()
    @collections.emailThreads.remove @currentEmailThread

    if @isSplitPaneMode() then @currentEmailThreadIs(null) else @goBack()
      
  ######################
  ### view functions ###
  ######################
    
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
