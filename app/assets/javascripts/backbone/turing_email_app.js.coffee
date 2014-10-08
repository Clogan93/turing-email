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
    
    @setupMainView()
    
    @setupSearchBar()
    @setupComposeButton()
    @setupFiltering()

    @setupToolbar()
    @setupUser()

    # email folders
    @setupEmailFolders()
    @loadEmailFolders()

    @setupComposeView()
    @setupEmailThreads()
    @setupRouters()

    Backbone.history.start() if not Backbone.History.started
    
    windowLocationHash = window.location.hash.toString()
    if windowLocationHash is ""
      @routers.emailFoldersRouter.navigate("#email_folder/INBOX", trigger: true)

    #@startEmailSync()

  startEmailSync: ->
    window.setInterval @syncEmail, 60000

  #######################
  ### Setup Functions ###
  #######################

  # TODO implement
  setupSplitPaneResizing: ->
    return
    # if TuringEmailApp.isSplitPaneMode()
    #   $("#resize_border").mousedown ->
    #     TuringEmailApp.mouseStart = null
    #     $(document).mousemove (event) ->
    #       if !TuringEmailApp.mouseStart?
    #         TuringEmailApp.mouseStart = event.pageY
    #       if event.pageY - TuringEmailApp.mouseStart > 100
    #         $("#preview_panel").height("30%")
    #         TuringEmailApp.mouseStart = null
    #       return
    
    #     $(document).one "mouseup", ->
    #       $(document).unbind "mousemove"

  # TODO implement
  setupKeyboardShortcuts: ->
    return
    #$("#email_table_body tr:nth-child(1)").addClass("email_thread_highlight")
  
  setupMainView: ->
    @views.mainView = new TuringEmailApp.Views.Main(
      app: TuringEmailApp
      el: $("#main")
    )
    @views.mainView.render()

  setupSearchBar: ->
    $("#top-search-form").submit (event) =>
      event.preventDefault();
      @searchClicked($(event.target).find("input").val())

  setupComposeButton: ->
    $("#compose_button").click =>
      @views.composeView.loadEmpty()

  setupFiltering: ->
    $(".create_filter").click (event) ->
      event.preventDefault()
      $('.dropdown a').trigger('click.bs.dropdown')

    $("#filter_form").submit ->
      url = "/api/v1/genie_rules"
      $.post url, $("#filter_form").serialize()

      $('.dropdown a').trigger('click.bs.dropdown')

      return false # avoid to execute the actual submit of the form.
      
  setupToolbar: ->
    @views.toolbarView = @views.mainView.toolbarView

    @listenTo(@views.toolbarView, "checkAllClicked", @checkAllClicked)
    @listenTo(@views.toolbarView, "checkAllReadClicked", @checkAllReadClicked)
    @listenTo(@views.toolbarView, "checkAllUnreadClicked", @checkAllUnreadClicked)
    @listenTo(@views.toolbarView, "uncheckAllClicked", @uncheckAllClicked)
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
    
    @listenTo(@views.emailFoldersTreeView, "emailFolderSelected", @emailFolderSelected)
    
  setupComposeView: ->
    @views.composeView = @views.mainView.composeView

    @listenTo(@views.composeView, "change:draft", @draftChanged)
    
  setupEmailThreads: ->
    @collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()
    @views.emailThreadsListView = @views.mainView.createEmailThreadsListView(@collections.emailThreads)

    @listenTo(@views.emailThreadsListView, "listItemSelected", @listItemSelected)
    @listenTo(@views.emailThreadsListView, "listItemDeselected", @listItemDeselected)
    @listenTo(@views.emailThreadsListView, "listItemChecked", @listItemChecked)
    @listenTo(@views.emailThreadsListView, "listItemUnchecked", @listItemUnchecked)

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

  currentEmailThreadIs: (emailThreadUID=".") ->
    if emailThreadUID != "."
      @loadEmailThread(emailThreadUID, (emailThread) =>
        return if @currentEmailThreadView?.model is emailThread

        @views.emailThreadsListView.select(emailThread, silent: true)
        @showEmailThread(emailThread)
        
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
        @moveTuringEmailReportToTop(@views.emailThreadsListView)
        
        if @isSplitPaneMode() && @collections.emailThreads.length > 0 &&
           not @collections.emailThreads.models[0].get("emails")[0].draft_id?
          @currentEmailThreadIs(@collections.emailThreads.models[0].get("uid"))

        emailFolder = @collections.emailFolders.getEmailFolder(emailFolderID)
        @views.emailFoldersTreeView.select(emailFolder, silent: true)
        @trigger("change:currentEmailFolder", this, emailFolder, parseInt(@collections.emailThreads.page))
  
        @showEmails()
    )
    
  ######################
  ### Sync Functions ###
  ######################

  syncEmail: ->
    $.post("api/v1/email_accounts/sync").done((data, status) =>
      if data.synced_emails
        @reloadEmailThreads()
    )
    
  #######################
  ### Alert Functions ###
  #######################
  
  showAlert: (text, classType) ->
    @removeAlert(@currentAlert.data("token")) if @currentAlert?
    
    html = '<div class="text-center alert ' + classType + '" role="alert" style="z-index: 2000; margin-bottom: 0px;">' + text + '</div>'
    @currentAlert = $(html).prependTo("body")
    @currentAlert.data("token", _.uniqueId())
    
    return @currentAlert.data("token")
    
  removeAlert: (token) ->
    return if not @currentAlert? || @currentAlert.data("token") != token
    @currentAlert.remove()
    @currentAlert = undefined

  ##############################
  ### Email Folder Functions ###
  ##############################
    
  loadEmailFolders: ->
    @collections.emailFolders.fetch(
      reset: true

      success: (collection, response, options) =>
        @trigger("change:emailFolders", this, collection)
    )

  ##############################
  ### Email Thread Functions ###
  ##############################
    
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
        
      error: myOptions?.error
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

    (if @isSplitPaneMode() then @currentEmailThreadIs(null) else @goBackClicked()) if clearSelection

  ######################
  ### General Events ###
  ######################

  checkAllClicked: ->
    @views.emailThreadsListView.checkAll()
    
  checkAllReadClicked: ->
    @views.emailThreadsListView.checkAllRead()
  
  checkAllUnreadClicked: ->
    @views.emailThreadsListView.checkAllUnread()
  
  uncheckAllClicked: ->
    @views.emailThreadsListView.uncheckAll()

  readClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.seenIs(true)
        @views.emailThreadsListView.markEmailThreadRead(@selectedEmailThread())
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        listItemView.model.seenIs(true) for listItemView in checkedListItemViews
        @views.emailThreadsListView.markCheckedRead()
      false, false
    )

  unreadClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.seenIs(false)
        @views.emailThreadsListView.markEmailThreadUnread(@selectedEmailThread())
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        listItemView.model.seenIs(false) for listItemView in checkedListItemViews
        @views.emailThreadsListView.markCheckedUnread()
      false, false
    )

  leftArrowClicked: ->
    if @collections.emailThreads.page > 1
      @routers.emailFoldersRouter.navigate("#email_folder/" + @selectedEmailFolderID() + "/" +
                                           (@collections.emailThreads.page - 1),
                                           trigger: true)

  rightArrowClicked: ->
    if @collections.emailThreads.length is TuringEmailApp.Models.UserSettings.EmailThreadsPerPage
      @routers.emailFoldersRouter.navigate("#email_folder/" + @selectedEmailFolderID() + "/" +
                                           (@collections.emailThreads.page + 1),
                                           trigger: true)

  labelAsClicked: (labelID) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.applyGmailLabel(labelID)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.applyGmailLabel(selectedEmailThreadUIDs, labelID)
      false, false
    )

  moveToFolderClicked: (folderID) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.moveToFolder(folderID)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.moveToFolder(selectedEmailThreadUIDs, folderID)
      true, true
    )

  refreshClicked: ->
    @reloadEmailThreads()

  searchClicked: (query) ->
    @routers.searchResultsRouter.navigate("#search/" + query, trigger: true)

  goBackClicked: ->
    @routers.emailFoldersRouter.showFolder(@selectedEmailFolderID())

  replyClicked: ->
    @showEmailEditorWithEmailThread(@selectedEmailThread().get("uid"), "reply")

  forwardClicked: ->
    @showEmailEditorWithEmailThread(@selectedEmailThread().get("uid"), "forward")

  archiveClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.removeFromFolder(@selectedEmailFolderID())
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.removeFromFolder(selectedEmailThreadUIDs, @selectedEmailFolderID())
      true, true
    )

  trashClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.trash()
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.trash(selectedEmailThreadUIDs)
      true, true
    )

  #############################
  ### EmailThreads.ListView ###
  #############################

  listItemSelected: (listView, listItemView) ->
    emailThread = listItemView.model
    isDraft = emailThread.get("emails")[0].draft_id? && @selectedEmailFolder()?.get("label_id") is "DRAFT"
    emailThreadUID = emailThread.get("uid")

    if isDraft
      @routers.emailThreadsRouter.navigate("#email_draft/" + emailThreadUID, trigger: true)
    else
      @routers.emailThreadsRouter.navigate("#email_thread/" + emailThreadUID, trigger: true)

  listItemDeselected: (listView, listItemView) ->
    @routers.emailThreadsRouter.navigate("#email_thread/.", trigger: true)

  listItemChecked: (listView, listItemView) ->
    @currentEmailThreadView.$el.hide() if @currentEmailThreadView

  listItemUnchecked: (listView, listItemView) ->
    if @views.emailThreadsListView.getCheckedListItemViews().length is 0
      @currentEmailThreadView.$el.show() if @currentEmailThreadView

  ####################################
  ### EmailFolders.TreeView Events ###
  ####################################

  emailFolderSelected: (treeView, emailFolder) ->
    return if not emailFolder?

    emailFolderID = emailFolder.get("label_id")

    emailFolderURL = "#email_folder/" + emailFolderID
    if window.location.hash is emailFolderURL
      @routers.emailFoldersRouter.showFolder(emailFolderID)
    else
      @routers.emailFoldersRouter.navigate("#email_folder/" + emailFolderID, trigger: true)

  ##########################
  ### ComposeView Events ###
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
    emailThreadView = @views.mainView.showEmailThread(emailThread, @isSplitPaneMode())

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

  moveTuringEmailReportToTop: (emailThreadsListView) ->
    for listItemView in _.values(emailThreadsListView.listItemViews)
      emailThread = listItemView.model
      
      if emailThread.get("emails")[0].subject is "Turing Email - Your daily Genie Report!"
        emailThreadsListView.collection.remove(emailThread)
        emailThreadsListView.collection.unshift(emailThread)

        trReportEmail = listItemView.$el
        trReportEmail.remove()
        emailThreadsListView.$el.prepend(trReportEmail)

        return
    
  showEmails: ->
    @views.mainView.showEmails()

  showSettings: ->
    @views.mainView.showSettings()
    
  showAnalytics: ->
    @views.mainView.showAnalytics()

  showReport: (divReportsID, ReportModel, ReportView) ->
    @views.mainView.showReport(divReportsID, ReportModel, ReportView)

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
