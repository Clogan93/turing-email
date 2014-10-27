#= require_self
#= require_tree ./templates
#= require ./models/email
#= require_tree ./models
#= require_tree ./collections
#= require ./views/email_threads/list_item_view
#= require ./views/email_threads/list_view
#= require ./views/app/compose/compose_view
#= require_tree ./views
#= require_tree ./routers

window.backboneWrapError = (model, options) ->
  error = options.error
  options.error = (resp) ->
    error model, resp, options  if error
    model.trigger "error", model, resp, options
    return

  return

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
    
    @setupGmailAPI()
    
    @setupKeyboardHandler()
    
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
    @setupCreateFolderView()
    @setupEmailThreads()
    @setupRouters()

    Backbone.history.start() if not Backbone.History.started
    
    windowLocationHash = window.location.hash.toString()
    if windowLocationHash is ""
      @routers.emailFoldersRouter.navigate("#email_folder/INBOX", trigger: true)

    window.setTimeout(=>
      @syncEmail()
    , 60000)

  #######################
  ### Setup Functions ###
  #######################

  setupGmailAPI: ->
    @gmailAPIReady = false

    gapi.client.load("gmail", "v1").then(=>
      @refreshGmailAPIToken().done(=>
        @gmailAPIReady = true
      )
    )
    
  refreshGmailAPIToken: ->
    $.get("/api/v1/gmail_accounts/get_token").done(
      (data, status) =>
        gapi.auth.setToken(data)
    )

  setupKeyboardHandler: ->
    @keyboardHandler = new TuringEmailAppKeyboardHandler(this)
  
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
    $(".compose_button").click =>
      @views.composeView.loadEmpty()
      @views.composeView.show()

  setupFiltering: ->
    $(".create_filter").click (event) ->
      event.preventDefault()
      $("#email-rule-dropdown a").trigger('click.bs.dropdown')
      return false

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
    @listenTo(@views.toolbarView, "createNewLabelClicked", @createNewLabelClicked)
    @listenTo(@views.toolbarView, "createNewEmailFolderClicked", @createNewEmailFolderClicked)

    @trigger("change:toolbarView", this, @views.toolbarView)

  setupUser: ->
    @models.user = new TuringEmailApp.Models.User()
    @models.user.fetch()

    @models.userSettings = new TuringEmailApp.Models.UserSettings()
    @models.userSettings.fetch()
    
    @listenTo(@models.userSettings, "change:keyboard_shortcuts_enabled", =>
      if @models.userSettings.get("keyboard_shortcuts_enabled")
        @keyboardHandler.start()
      else
        @keyboardHandler.stop()
    )

  setupEmailFolders: ->
    @collections.emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(undefined, app: TuringEmailApp)
    @views.emailFoldersTreeView = new TuringEmailApp.Views.EmailFolders.TreeView(
      app: this
      el: $(".email_folders")
      collection: @collections.emailFolders
    )
    
    @listenTo(@views.emailFoldersTreeView, "emailFolderSelected", @emailFolderSelected)
    
  setupComposeView: ->
    @views.composeView = @views.mainView.composeView

    @listenTo(@views.composeView, "change:draft", @draftChanged)

  setupCreateFolderView: ->
    @views.createFolderView = @views.mainView.createFolderView

    @listenTo(@views.createFolderView, "createFolderFormSubmitted", (createFolderView, mode, folderName) => @createFolderFormSubmitted(mode, folderName))

  setupEmailThreads: ->
    @collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined, app: this)
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

  currentEmailFolderIs: (emailFolderID, pageTokenIndex) ->
    @collections.emailThreads.folderIDIs(emailFolderID)
    @collections.emailThreads.pageTokenIndexIs(parseInt(pageTokenIndex)) if pageTokenIndex?

    @reloadEmailThreads(
      success: (collection, response, options) =>
        emailFolder = @collections.emailFolders.getEmailFolder(emailFolderID)
        @views.emailFoldersTreeView.select(emailFolder, silent: true)
        @trigger("change:currentEmailFolder", this, emailFolder, @collections.emailThreads.pageTokenIndex + 1)
  
        @showEmails()

        if @isSplitPaneMode() && @collections.emailThreads.length > 0 &&
            not @collections.emailThreads.models[0].get("emails")?[0].draft_id?
          @currentEmailThreadIs(@collections.emailThreads.models[0].get("uid"))
    )

  ######################
  ### Sync Functions ###
  ######################

  syncEmail: ->
    @reloadEmailThreads()
    @loadEmailFolders()

    window.setTimeout(=>
      @syncEmail()
    , 60000)
    
  #######################
  ### Alert Functions ###
  #######################
  
  showAlert: (text, classType) ->
    @removeAlert(@currentAlert.data("token")) if @currentAlert?
    
    html = '<div class="text-center alert ' + classType +
           '" role="alert" style="z-index: 2000; margin-bottom: 0px; position: absolute; width: 100%;">' + text +
           '</div>'
    
    @currentAlert = $(html).prependTo("body")
    @currentAlert.data("token", _.uniqueId())

    token = @currentAlert.data("token")
    
    dismissDiv = $('<span class="dismiss-alert"> (<span class="dismiss-alert-link">dismiss</span>)</span>').appendTo(@currentAlert)
    dismissDiv.find(".dismiss-alert-link").click(=>
      @removeAlert(token)
    )
    
    return token
    
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
      emailThread = new TuringEmailApp.Models.EmailThread(undefined,
        app: TuringEmailApp
        emailThreadUID: emailThreadUID
      )
      emailThread.fetch(
        success: (model, response, options) =>
          callback?(emailThread)
      )
      
  reloadEmailThreads: (myOptions) ->
    selectedEmailThread = @selectedEmailThread()

    @collections.emailThreads.fetch(
      query: myOptions?.query
      reset: true
      
      success: (collection, response, options) =>
        @stopListening(emailThread) for emailThread in options.previousModels

        for emailThread in collection.models
          @listenTo(emailThread, "change:seen", @emailThreadSeenChanged)
          @listenTo(emailThread, "change:folder", @emailThreadFolderChanged)

        @moveTuringEmailReportToTop(@views.emailThreadsListView)

        if selectedEmailThread? && not @selectedEmailThread()?
          emailThreadToSelect = collection.getEmailThread(selectedEmailThread.get("uid"))

          if emailThreadToSelect?
            @ignoreListItemSelected = true
            @views.emailThreadsListView.select(emailThreadToSelect)
            @ignoreListItemSelected = false
        
        myOptions.success(collection, response, options) if myOptions?.success?
        
      error: myOptions?.error
    )

  loadSearchResults: (query) ->
    @reloadEmailThreads(
      query: query
      
      success: (collection, response, options) =>
        @showEmails()
    )

  applyActionToSelectedThreads: (singleAction, multiAction, remove=false, clearSelection=false, refreshFolders=false, moveSelection=false) ->
    checkedListItemViews = @views.emailThreadsListView.getCheckedListItemViews()

    if checkedListItemViews.length == 0
      selectedIndex = @views.emailThreadsListView.selectedIndex()
      singleAction()
      @collections.emailThreads.remove @selectedEmailThread() if remove
      (if @isSplitPaneMode() then @currentEmailThreadIs() else @goBackClicked()) if clearSelection and not moveSelection
      @views.emailThreadsListView.selectedIndexIs selectedIndex if moveSelection
    else
      selectedEmailThreads = []
      selectedEmailThreadUIDs = []
      
      for listItemView in checkedListItemViews
        selectedEmailThreads.push(listItemView.model)
        selectedEmailThreadUIDs.push(listItemView.model.get("uid"))
      
      multiAction(checkedListItemViews, selectedEmailThreadUIDs)
      
      @collections.emailThreads.remove selectedEmailThreads if remove

      (if @isSplitPaneMode() then @currentEmailThreadIs() else @goBackClicked()) if clearSelection

    @loadEmailFolders() if refreshFolders

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
        @selectedEmailThread()?.set("seen", true)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        listItemView.model.set("seen", true) for listItemView in checkedListItemViews
      false, false
    )

  unreadClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.set("seen", false)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        listItemView.model.set("seen", false) for listItemView in checkedListItemViews
      false, false
    )

  leftArrowClicked: ->
    if @collections.emailThreads.hasPreviousPage()
      @routers.emailFoldersRouter.navigate("#email_folder/" + @selectedEmailFolderID() + "/" +
                                           (@collections.emailThreads.pageTokenIndex - 1),
                                           trigger: true)

  rightArrowClicked: ->
    if @collections.emailThreads.hasNextPage()
      @routers.emailFoldersRouter.navigate("#email_folder/" + @selectedEmailFolderID() + "/" +
                                           (@collections.emailThreads.pageTokenIndex + 1),
                                           trigger: true)

  labelAsClicked: (labelID, labelName) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.applyGmailLabel(labelID, labelName)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.applyGmailLabel(selectedEmailThreadUIDs, labelID, labelName)
      false, false
    )

  moveToFolderClicked: (folderID, folderName) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.moveToFolder(folderID, folderName)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.moveToFolder(selectedEmailThreadUIDs, folderID, folderName)
      true, true, true, true
    )

  refreshClicked: ->
    @reloadEmailThreads()

  searchClicked: (query) ->
    @routers.searchResultsRouter.navigate("#search/" + query, trigger: true)

  goBackClicked: ->
    @routers.emailFoldersRouter.showFolder(@selectedEmailFolderID())

  replyClicked: ->
    return false if not @selectedEmailThread()?
    
    @showEmailEditorWithEmailThread(@selectedEmailThread().get("uid"), "reply")
    return @selectedEmailThread()

  forwardClicked: ->
    return false if not @selectedEmailThread()?
    
    @showEmailEditorWithEmailThread(@selectedEmailThread().get("uid"), "forward")
    return @selectedEmailThread()

  archiveClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.removeFromFolder(@selectedEmailFolderID())
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.removeFromFolder(selectedEmailThreadUIDs, @selectedEmailFolderID())
      true, true, true, true
    )

  trashClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.trash()
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.trash(selectedEmailThreadUIDs)
      true, true, true, true
    )

  createNewLabelClicked: ->
    @views.createFolderView.show("label")

  createNewEmailFolderClicked: ->
    @views.createFolderView.show("folder")

  #############################
  ### EmailThreads.ListView ###
  #############################

  listItemSelected: (listView, listItemView) ->
    return if @ignoreListItemSelected? && @ignoreListItemSelected

    emailThread = listItemView.model
    emailThreadUID = emailThread.get("uid")

    @views.mainView.toolbarView.refreshToolbarButtonView.hide()
    @routers.emailThreadsRouter.navigate("#email_thread/" + emailThreadUID, trigger: true)

  listItemDeselected: (listView, listItemView) ->
    @views.mainView.toolbarView.refreshToolbarButtonView.show()

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
    
  draftChanged: (composeView, draft, emailThreadParent) ->
    if emailThreadParent?
      emails = _.clone(emailThreadParent.get("emails"))
      
      for index in [emails.length-1 .. 0]
        email = emails[index]
        
        if email["draft_id"] == draft.get("draft_id")
          emails.splice(index, 1)
          break

      emails.push(draft.toJSON())
      emailThreadParent.set("emails", emails)
      
    @reloadEmailThreads()
    @loadEmailFolders()

  ###############################
  ### CreateFolderView Events ###
  ###############################

  createFolderFormSubmitted: (mode, folderName) ->
    if mode == "label"
      @labelAsClicked undefined, folderName
    else
      @moveToFolderClicked undefined, folderName

  ##########################
  ### EmailThread Events ###
  ##########################

  emailThreadSeenChanged: (emailThread, seenValue) ->
    delta = if seenValue then -1 else 1
      
    for folderID in emailThread.get("folder_ids")
      folder = @collections.emailFolders.getEmailFolder(folderID)
      continue if not folder?
      
      folder.set("num_unread_threads", folder.get("num_unread_threads") + delta)
      @trigger("change:emailFolderUnreadCount", this, folder)

  emailThreadFolderChanged: (emailThread, newFolder) ->
    folder = @collections.emailFolders.getEmailFolder(newFolder["label_id"])

    @loadEmailFolders() if not folder?

  ######################
  ### View Functions ###
  ######################

  isSplitPaneMode: ->
    splitPaneMode = @models.userSettings.get("split_pane_mode")
    return splitPaneMode is "horizontal" || splitPaneMode is "vertical"
    
  showEmailThread: (emailThread) ->
    emailThreadView = @views.mainView.showEmailThread(emailThread, @isSplitPaneMode())

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

      sortedEmails = emailThread.sortedEmails()
      
      switch mode
        when "forward"
          @views.composeView.loadEmailAsForward(_.last(sortedEmails), emailThread)
        when "reply"
          @views.composeView.loadEmailAsReply(_.last(sortedEmails), emailThread)
        else
          @views.composeView.loadEmailDraft(_.last(sortedEmails), emailThread)

      @views.composeView.show()
    )

  moveTuringEmailReportToTop: (emailThreadsListView) ->
    for listItemView in _.values(emailThreadsListView.listItemViews)
      emailThread = listItemView.model
      
      if emailThread.get("subject") is "Turing Email - Your daily Genie Report!"
        emailThreadsListView.collection.remove(emailThread)
        emailThreadsListView.collection.unshift(emailThread)

        trReportEmail = listItemView.$el
        trReportEmail.remove()
        emailThreadsListView.$el.prepend(trReportEmail)

        return

  showEmails: ->
    @views.mainView.showEmails(@isSplitPaneMode())

  showSettings: ->
    if _.keys(@models.userSettings.attributes).length is 0
      setTimeout(
        =>
          @showSettings()
        100
      )

      return

    @collections.emailRules = new TuringEmailApp.Collections.Rules.EmailRulesCollection()
    @collections.emailRules.fetch(reset: true)

    @collections.brainRules = new TuringEmailApp.Collections.Rules.BrainRulesCollection()
    @collections.brainRules.fetch(reset: true)

    @views.mainView.showSettings()

  showAnalytics: ->
    @views.mainView.showAnalytics()

  showReport: (ReportModel, ReportView) ->
    @views.mainView.showReport(ReportModel, ReportView)

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
