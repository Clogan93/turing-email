#= require_self
#= require_tree ./templates
#= require ./models/email
#= require_tree ./models
#= require_tree ./collections
#= require ./views/email_threads/list_item_view
#= require ./views/email_threads/list_view
#= require_tree ./views
#= require_tree ./routers
  
window.TuringEmailApp = new(Backbone.View.extend(
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

    Backbone.history.start()
    
    windowLocationHash = window.location.hash.toString()
    if windowLocationHash is ""
      @routers.emailFoldersRouter.navigate("#email_folder/INBOX", trigger: true)

    #@startEmailSync()

  startEmailSync: ->
    window.setInterval (->
      $.post("api/v1/email_accounts/sync").done((data, status) =>
        if data.synced_emails
          @reloadEmailThreads()
      )
    ), 60000

  #######################
  ### Setup Functions ###
  #######################
    
  setupToolbar: ->
    @views.toolbarView = new TuringEmailApp.Views.ToolbarView(
      app: this
      el: $("#email-folder-mail-header")
    )
    
    @views.toolbarView.render()

    @listenTo(@views.toolbarView, "selectAll", => @views.emailThreadsListView.selectAll())
    @listenTo(@views.toolbarView, "selectAllRead", => @views.emailThreadsListView.selectAllRead())
    @listenTo(@views.toolbarView, "selectAllUnread", => @views.emailThreadsListView.selectAllUnread())
    @listenTo(@views.toolbarView, "deselectAll", => @views.emailThreadsListView.deselectAll())

    @listenTo(@views.toolbarView, "readClicked", @readClicked)
    @listenTo(@views.toolbarView, "unreadClicked", @unreadClicked)
    @listenTo(@views.toolbarView, "archiveClicked", @archiveClicked)
    @listenTo(@views.toolbarView, "trashClicked", @trashClicked)
    @listenTo(@views.toolbarView, "leftArrowClicked", @leftArrowClicked)
    @listenTo(@views.toolbarView, "rightArrowClicked", @rightArrowClicked)
    @listenTo(@views.toolbarView, "labelAsClicked", (toolbarView, labelID) => @labelAsClicked(labelID))
    @listenTo(@views.toolbarView, "moveToFolderClicked", (toolbarView, folderID) => @moveToFolderClicked(folderID))
    @listenTo(@views.toolbarView, "refreshClicked", @refreshClicked)
    @listenTo(@views.toolbarView, "searchClicked", (toolbarView, query) => @searchClicked(query))
    
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
    @collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      page: getQuerystringNameValue("page")
    )
    @views.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView(
      app: this
      el: $("#email_table_body")
      collection: TuringEmailApp.collections.emailThreads
    )

    @listenTo(@views.emailThreadsListView, "change:selection", (listView, emailThread) =>
      isDraft = emailThread.get("emails")[0].draft_id?
      emailThreadUID = emailThread.get("uid")

      if isDraft
        @routers.emailThreadsRouter.navigate("#email_draft/" + emailThreadUID, trigger: true)
      else
        @routers.emailThreadsRouter.navigate("#email_thread/" + emailThreadUID, trigger: true)
    )
    
    @listenTo(@views.emailThreadsListView, "listItemChecked", (listView, emailThread) =>
      @currentEmailThreadView.$el.hide()
    )

    @listenTo(@views.emailThreadsListView, "listItemUnchecked", (listView, emailThread) =>
      if @views.emailThreadsListView.getSelectedEmailThreads().length is 0
        @currentEmailThreadView.$el.show()
    )
  
  setupRouters: ->
    @routers.emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()
    @routers.emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()
    @routers.analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()
    @routers.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
    @routers.settingsRouter = new TuringEmailApp.Routers.SettingsRouter()
    @routers.searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()

  ###############
  ### Setters ###
  ###############

  currentEmailThreadIs: (emailThreadUID, forceReload = false) ->
    return if not forceReload && @currentEmailThread?.get("uid") is emailThreadUID

    if emailThreadUID
      TuringEmailApp.loadEmailThread(emailThreadUID, (emailThread) =>
        return if @currentEmailThread is emailThread

        @showEmailThread(emailThread)
        @views.toolbarView.deselectAllCheckbox()
        @trigger "change:currentEmailThread", this, emailThread
      )
    else
      @showEmailThread()
      @views.toolbarView.deselectAllCheckbox()
      @trigger "change:currentEmailThread", this, null

# TODO write tests (page param)
  currentEmailFolderIs: (emailFolderID, page) ->
    TuringEmailApp.collections.emailThreads.setupURL(emailFolderID, page)

    @reloadEmailThreads(
      success: (collection, response, options) ->
        if TuringEmailApp.isSplitPaneMode() && TuringEmailApp.collections.emailThreads.length > 0
          TuringEmailApp.currentEmailThreadIs(TuringEmailApp.collections.emailThreads.models[0].get("uid"))
    )

    TuringEmailApp.currentFolderID = emailFolderID
    @trigger "change:currentEmailFolder", this, emailFolderID

    TuringEmailApp.showEmails()

  #################
  ### Functions ###
  #################
    
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

        @trigger("change:emailFolders", this)
    )
    
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
      
  reloadEmailThreads: (myOptions) ->
    @collections.emailThreads.fetch(
      reset: true
      
      success: (collection, response, options) =>
        @stopListening(emailThread) for emailThread in options.previousModels
        @listenTo(emailThread, "change:seen", @emailThreadSeenChanged) for emailThread in collection.models

        myOptions.success(collection, response, options) if myOptions?.success?
        
      error: options?.error
    )

  applyActionToSelectedThreads: (singleAction, multiAction, remove=false, clearSelection=false) ->
    selectedEmailThreads = @views.emailThreadsListView.getSelectedEmailThreads()

    if selectedEmailThreads.length == 0
      singleAction()
      @collections.emailThreads.remove @currentEmailThread if remove
    else
      selectedEmailThreadUIDs = (emailThread.get("uid") for emailThread in selectedEmailThreads)
      multiAction(selectedEmailThreads, selectedEmailThreadUIDs)
      @collections.emailThreads.remove selectedEmailThreads if remove

    (if @isSplitPaneMode() then @currentEmailThreadIs(null) else goBackClicked()) if clearSelection

  ######################
  ### General Events ###
  ######################

  readClicked: ->
    @applyActionToSelectedThreads(
      =>
        @currentEmailThread.seenIs(true)
        @views.emailThreadsListView.markEmailThreadRead(@currentEmailThread)
      (selectedEmailThreads, selectedEmailThreadUIDs) =>
        emailThread.seenIs(true) for emailThread in selectedEmailThreads
        @views.emailThreadsListView.markSelectedRead()
      false, false
    )

  unreadClicked: ->
    @applyActionToSelectedThreads(
      =>
        @currentEmailThread.seenIs(false)
        @views.emailThreadsListView.markEmailThreadUnread(@currentEmailThread)
      (selectedEmailThreads, selectedEmailThreadUIDs) =>
        emailThread.seenIs(false) for emailThread in selectedEmailThreads
        @views.emailThreadsListView.markSelectedUnread()
      false, false
    )

  leftArrowClicked: ->
    @collections.emailThreads.previousPage((collection, response, options) =>
      @views.toolbarView.updatePaginationText @currentFolderID
    )

  rightArrowClicked: ->
    if @collections.emailThreads.length is TuringEmailApp.Models.UserSettings.EmailThreadsPerPage
      @collections.emailThreads.nextPage((collection, response, options) =>
        @views.toolbarView.updatePaginationText @currentFolderID
      )

  labelAsClicked: (labelID) ->
    @applyActionToSelectedThreads(
      =>
        @currentEmailThread.applyGmailLabel(labelID)
      (selectedEmailThreads, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.applyGmailLabel(selectedEmailThreadUIDs, labelID)
      false, false
    )

  moveToFolderClicked: (folderID) ->
    @applyActionToSelectedThreads(
      =>
        @currentEmailThread.moveToFolder(folderID)
      (selectedEmailThreads, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.moveToFolder(selectedEmailThreadUIDs, folderID)
      false, false
    )

  refreshClicked: ->
    @reloadEmailThreads()

  searchClicked: (query) ->
    @routers.searchResultsRouter.navigate("#search/" + query, trigger: true)

  goBackClicked: ->
    @routers.emailFoldersRouter.showFolder(TuringEmailApp.currentFolderID)

  replyClicked: ->
    @showEmailEditorWithEmailThread(@currentEmailThread.get("uid"), "reply")

  forwardClicked: ->
    @showEmailEditorWithEmailThread(TuringEmailApp.currentEmailThread.get("uid"), "forward")

  archiveClicked: ->
    @applyActionToSelectedThreads(
      =>
        @currentEmailThread.removeFromFolder(@currentFolderID)
      (selectedEmailThreads, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.removeFromFolder(selectedEmailThreadUIDs, @currentFolderID)
      true, true
    )

  trashClicked: ->
    @applyActionToSelectedThreads(
      =>
        @currentEmailThread.trash()
      (selectedEmailThreads, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.trash(selectedEmailThreadUIDs)
      true, true
    )

  ##########################
  ### ComposeView #vents ###
  ##########################
    
  draftChanged: ->
    @reloadEmailThreads() if TuringEmailApp.currentFolderID is "DRAFT"

  ##########################
  ### EmailThread Events ###
  ##########################

  # TODO for now assumes the email thred is in the current folder but it might be in a different folder
  emailThreadSeenChanged: (emailThread, seenValue) ->
    currentFolder = TuringEmailApp.collections.emailFolders.getEmailFolder(@currentFolderID)
    
    if currentFolder?
      delta = if seenValue then -1 else 1
      currentFolder.set("num_unread_threads", currentFolder.get("num_unread_threads") + delta)
      @trigger("change:emailFolderUnreadCount", this, currentFolder)
    
  ######################
  ### View Functions ###
  ######################

  isSplitPaneMode: ->
    splitPaneMode = TuringEmailApp.models.userSettings.get("split_pane_mode")
    return splitPaneMode is "horizontal" || splitPaneMode is "vertical"

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
    emailThreadView.$el.show()

    @listenTo(emailThreadView, "goBackClicked", @goBackClicked)
    @listenTo(emailThreadView, "replyClicked", @replyClicked)
    @listenTo(emailThreadView, "forwardClicked", @forwardClicked)
    @listenTo(emailThreadView, "archiveClicked", @archiveClicked)
    @listenTo(emailThreadView, "trashClicked", @trashClicked)

    if @currentEmailThreadView?
      @stopListening(@currentEmailThreadView)
      @currentEmailThreadView.stopListening()

    @currentEmailThreadView = emailThreadView

  showEmailEditorWithEmailThread: (emailThreadUID, mode="draft") ->
    TuringEmailApp.loadEmailThread(emailThreadUID, (emailThread) =>
      TuringEmailApp.currentEmailThreadIs emailThread.get("uid")

      switch mode
        when "forward"
          TuringEmailApp.views.composeView.loadEmailAsForward(emailThread.get("emails")[0])
        when "reply"
          TuringEmailApp.views.composeView.loadEmailAsReply(emailThread.get("emails")[0])
        else
          TuringEmailApp.views.composeView.loadEmailDraft emailThread.get("emails")[0]

      TuringEmailApp.views.composeView.show()
    )
    
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

))(el: document.body)

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
