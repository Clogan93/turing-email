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
    
    @setupSearchBar()
    @setupComposeButton()

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
    
  setupSearchBar: ->
    $("#top-search-form").submit (event) =>
      event.preventDefault();
      @searchClicked($(event.target).find("input").val())

  setupComposeButton: ->
    $("#compose_button").click =>
      @views.composeView.loadEmpty()
      
  setupToolbar: ->
    @views.toolbarView = new TuringEmailApp.Views.ToolbarView(
      app: this
      el: $("#email-folder-mail-header")
    )
    
    @views.toolbarView.render()

    @listenTo(@views.toolbarView, "checkAll", => @views.emailThreadsListView.checkAll())
    @listenTo(@views.toolbarView, "checkAllRead", => @views.emailThreadsListView.checkAllRead())
    @listenTo(@views.toolbarView, "checkAllUnread", => @views.emailThreadsListView.checkAllUnread())
    @listenTo(@views.toolbarView, "uncheckAll", => @views.emailThreadsListView.uncheckAll())

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
      collection: @collections.emailThreads
    )

    @listenTo(@views.emailThreadsListView, "listItemSelected", (listView, listItemView) =>
      emailThread = listItemView.model
      isDraft = emailThread.get("emails")[0].draft_id?
      emailThreadUID = emailThread.get("uid")

      if isDraft
        @routers.emailThreadsRouter.navigate("#email_draft/" + emailThreadUID, trigger: true)
      else
        @routers.emailThreadsRouter.navigate("#email_thread/" + emailThreadUID, trigger: true)
    )

    @listenTo(@views.emailThreadsListView, "listItemDeselected", (listView, listItemView) =>
      @routers.emailThreadsRouter.navigate("#email_thread/.", trigger: true)
    )
    
    @listenTo(@views.emailThreadsListView, "listItemChecked", (listView, listItemView) =>
      @currentEmailThreadView.$el.hide() if @currentEmailThreadView
    )

    @listenTo(@views.emailThreadsListView, "listItemUnchecked", (listView, listItemView) =>
      if @views.emailThreadsListView.getCheckedListItemViews().length is 0
        @currentEmailThreadView.$el.show() if @currentEmailThreadView
    )
  
  setupRouters: ->
    @routers.emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()
    @routers.emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()
    @routers.analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()
    @routers.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
    @routers.settingsRouter = new TuringEmailApp.Routers.SettingsRouter()
    @routers.searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()

  ###############
  ### Getters ###
  ###############

  selectedEmailThread: ->
    return @views.emailThreadsListView.selectedItem()
    
  selectedEmailFolder: ->
    return @views.emailFoldersTreeView.selectedItem()
    
  selectedEmailFolderID: ->
    return @views.emailFoldersTreeView.selectedItem()?.get("label_id")
    
  ###############
  ### Setters ###
  ###############

  currentEmailThreadIs: (emailThreadUID=".", forceReload=false) ->
    return if not forceReload && @currentEmailThreadView?.model?.get("uid") is emailThreadUID

    if emailThreadUID != "."
      @loadEmailThread(emailThreadUID, (emailThread) =>
        return if @currentEmailThreadView?.model is emailThread

        # do the show show first so then if the select below triggers this again it will exit above
        @showEmailThread(emailThread)
        
        @views.emailThreadsListView.select(emailThread)
        @views.toolbarView.uncheckAllCheckbox()
        
        @trigger "change:selectedEmailThread", this, emailThread
      )
    else
      # do the show show first so then if the select below triggers this again it will exit above
      @showEmailThread()
      @views.emailThreadsListView.deselect()
      @views.toolbarView.uncheckAllCheckbox()
      
      @trigger "change:selectedEmailThread", this, null

# TODO write tests (page param)
  currentEmailFolderIs: (emailFolderID, page) ->
    @collections.emailThreads.setupURL(emailFolderID, page)

    @reloadEmailThreads(
      success: (collection, response, options) =>
        if @isSplitPaneMode() && @collections.emailThreads.length > 0
          @currentEmailThreadIs(@collections.emailThreads.models[0].get("uid"))

        emailFolder = @collections.emailFolders.getEmailFolder(emailFolderID)
        @views.emailFoldersTreeView.select(emailFolder)
        @trigger "change:currentEmailFolder", this, emailFolder
  
        @showEmails()
    )

  #################
  ### Functions ###
  #################
    
  loadEmailFolders: ->
    @collections.emailFolders.fetch(
      reset: true

      success: (collection, response, options) =>
        @trigger("change:emailFolders", this, collection)
    )
    
  loadEmailThread: (emailThreadUID, callback) ->
    emailThread = @collections.emailThreads?.getEmailThread(emailThreadUID)

    if emailThread?
      callback(emailThread)
    else
      emailThread = new @Models.EmailThread(undefined, emailThreadUID: emailThreadUID)
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
    checkedListItemViews = @views.emailThreadsListView.getCheckedListItemViews()

    if checkedListItemViews.length == 0
      singleAction()
      @collections.emailThreads.remove @selectedEmailThread() if remove
    else
      selectedEmailThreads = []
      selectedEmailThreadUIDs = []
      
      for listItemView in checkedListItemViews
        selectedEmailThreads.push(listItemView.model)
        selectedEmailThreadUIDs.push(listItemView.model.get("uid"))
      
      multiAction(checkedListItemViews, selectedEmailThreadUIDs)
      
      @collections.emailThreads.remove selectedEmailThreads if remove

    (if @isSplitPaneMode() then @currentEmailThreadIs(null) else goBackClicked()) if clearSelection

  ######################
  ### General Events ###
  ######################

  readClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread().seenIs(true)
        @views.emailThreadsListView.markEmailThreadRead(@selectedEmailThread())
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        listItemView.model.seenIs(true) for listItemView in checkedListItemViews
        @views.emailThreadsListView.markCheckedRead()
      false, false
    )

  unreadClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread().seenIs(false)
        @views.emailThreadsListView.markEmailThreadUnread(@selectedEmailThread())
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        listItemView.model.seenIs(false) for listItemView in checkedListItemViews
        @views.emailThreadsListView.markCheckedUnread()
      false, false
    )

  leftArrowClicked: ->
    @collections.emailThreads.previousPage((collection, response, options) =>
      @views.toolbarView.updatePaginationText @selectedEmailFolderID()
    )

  rightArrowClicked: ->
    if @collections.emailThreads.length is TuringEmailApp.Models.UserSettings.EmailThreadsPerPage
      @collections.emailThreads.nextPage((collection, response, options) =>
        @views.toolbarView.updatePaginationText @selectedEmailFolderID()
      )

  labelAsClicked: (labelID) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread().applyGmailLabel(labelID)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.applyGmailLabel(selectedEmailThreadUIDs, labelID)
      false, false
    )

  moveToFolderClicked: (folderID) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread().moveToFolder(folderID)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.moveToFolder(selectedEmailThreadUIDs, folderID)
      true, true
    )

  refreshClicked: ->
    @reloadEmailThreads()

  searchClicked: (query) ->
    @routers.searchResultsRouter.navigate("#search/" + query, trigger: true)

  goBackClicked: ->
    @routers.emailFoldersRouter.showFolder(@currentFolderID)

  replyClicked: ->
    @showEmailEditorWithEmailThread(@selectedEmailThread().get("uid"), "reply")

  forwardClicked: ->
    @showEmailEditorWithEmailThread(@selectedEmailThread().get("uid"), "forward")

  archiveClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread().removeFromFolder(@selectedEmailFolderID())
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.removeFromFolder(selectedEmailThreadUIDs, @selectedEmailFolderID())
      true, true
    )

  trashClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread().trash()
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.trash(selectedEmailThreadUIDs)
      true, true
    )

  ##########################
  ### ComposeView #vents ###
  ##########################
    
  draftChanged: ->
    @reloadEmailThreads() if @selectedEmailFolderID() is "DRAFT"

  ##########################
  ### EmailThread Events ###
  ##########################

  # TODO for now assumes the email thred is in the current folder but it might be in a different folder
  emailThreadSeenChanged: (emailThread, seenValue) ->
    currentFolder = @collections.emailFolders.getEmailFolder(@selectedEmailFolderID())
    
    if currentFolder?
      delta = if seenValue then -1 else 1
      currentFolder.set("num_unread_threads", currentFolder.get("num_unread_threads") + delta)
      @trigger("change:emailFolderUnreadCount", this, currentFolder)
    
  ######################
  ### View Functions ###
  ######################

  isSplitPaneMode: ->
    splitPaneMode = @models.userSettings.get("split_pane_mode")
    return splitPaneMode is "horizontal" || splitPaneMode is "vertical"

  showEmailThread: (emailThread) ->
    if @isSplitPaneMode()
      $("#preview_panel").show()
      emailThreadViewSelector = "#preview_content"
    else
      emailThreadViewSelector = "#email_table_body"
      $("#email-folder-mail-header").hide()

    emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: emailThread
      el: $(emailThreadViewSelector)
    )
    emailThreadView.render()
    emailThreadView.$el.show()

    @views.emailThreadsListView.markEmailThreadRead(emailThread) if emailThread

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
    @loadEmailThread(emailThreadUID, (emailThread) =>
      @currentEmailThreadIs emailThread.get("uid")

      switch mode
        when "forward"
          @views.composeView.loadEmailAsForward(emailThread.get("emails")[0])
        when "reply"
          @views.composeView.loadEmailAsReply(emailThread.get("emails")[0])
        else
          @views.composeView.loadEmailDraft emailThread.get("emails")[0]

      @views.composeView.show()
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
