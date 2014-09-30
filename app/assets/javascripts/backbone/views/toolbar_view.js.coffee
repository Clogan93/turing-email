class TuringEmailApp.Views.ToolbarView extends Backbone.View
  @MAX_RETRY_ATTEMPTS: 5

  template: JST["backbone/templates/toolbar_view"]
  tagName: "div"

  initialize: (options) ->
    @listenTo(options.app, "change:currentEmailFolder", @currentEmailFolderChanged)
    @listenTo(options.app, "change:emailFolders", @emailFoldersChanged)
  
  render: ->
    emailFolders = TuringEmailApp.collections.emailFolders?.toJSON() ? []
    @$el.html(@template({'emailFolders' : emailFolders}))
    
    @setupSelectAllCheckbox()
    @divSelectAllICheck = @$el.find("div.icheckbox_square-green")
    
    @setupButtons()
    
    return this

  #######################
  ### Setup Functions ###
  #######################
    
  setupSelectAllCheckbox: ->
    @$el.find(".i-checks").iCheck
      checkboxClass: "icheckbox_square-green"
      radioClass: "iradio_square-green"

    @$el.find("div.icheckbox_square-green ins").click (event) =>
      if @selectAllIsChecked()
        @trigger("selectAll", this)
      else
        @trigger("deselectAll", this)

  setupButtons: ->
    @setupBulkActionButtons()
    @setupSearchButton()

    @$el.find("i.fa-eye").parent().click =>
      @trigger("readClicked", this)

    @$el.find("i.fa-eye-slash").parent().click =>
      @trigger("unreadClicked", this)

    @$el.find("i.fa-archive").parent().click =>
      @trigger("archiveClicked", this)

    @$el.find("i.fa-trash-o").parent().click =>
      @trigger("trashClicked", this)

    @$el.find("#paginate_left_link").click =>
      @trigger("leftArrowClicked", this)

    @$el.find("#paginate_right_link").click =>
      @trigger("rightArrowClicked", this)

    @$el.find(".label_as_link").click (event) =>
      @trigger("labelAsClicked", this, $(event.target).attr("name"))

    @$el.find(".move_to_folder_link").click (event) =>
      @trigger("moveToFolderClicked", this, $(event.target).attr("name"))

    @$el.find("#refresh_button").click =>
      @trigger("refreshClicked", this)

  setupBulkActionButtons: ->
    @$el.find("#all_bulk_action").click =>
      @divSelectAllICheck.iCheck("check")
      @trigger("selectAll", this)

    @$el.find("#none_bulk_action").click =>
      @divSelectAllICheck.iCheck("uncheck")
      @trigger("deselectAll", this)

    @$el.find("#read_bulk_action").click =>
      @trigger("selectAllRead", this)

    @$el.find("#unread_bulk_action").click =>
      @trigger("selectAllUnread", this)

  setupSearchButton: ->
    $el.find("#search_input").change ->
      $("a#search_button_link").attr("href", "#search/" + $(@).val())

    $el.find("#search_input").keypress (event) =>
      if event.which is 13
        event.preventDefault();
        @trigger("searchClicked", this, $(event.target).val())

  #################
  ### Functions ###
  #################

  selectAllIsChecked: ->
    return @divSelectAllICheck.hasClass "checked"
    
  deselectAllCheckbox: ->
    @divSelectAllICheck.iCheck("uncheck")

  updateTitle: (folderID, attempt=1) ->
    currentFolder = TuringEmailApp.collections.emailFolders.getEmailFolder(folderID)
    
    if currentFolder?
      @$el.find(".label_name").html(currentFolder.get("name"))
      if currentFolder.get("label_id") is "DRAFT" or currentFolder.get("label_id") is "SENT"
        @$el.find(".label_count_badge").html(currentFolder.get("num_threads"))
      else
        @$el.find(".label_count_badge").html(currentFolder.get("num_unread_threads"))
    else if attempt < TuringEmailApp.Views.ToolbarView.MAX_RETRY_ATTEMPTS
      setTimeout(
        =>
          @updateTitle(folderID, attempt + 1)
        500
      )

  updatePaginationText: (folderID, attempt=1) ->
    currentFolder = TuringEmailApp.collections.emailFolders.getEmailFolder(folderID)
    
    if currentFolder?
      numThreads = currentFolder.get("num_threads")
      @$el.find("#total_emails_number").html(numThreads)
      
      currentPage = parseInt(TuringEmailApp.collections.emailThreads.page)
      
      firstThreadNumber = (currentPage - 1) * 50 + 1
      @$el.find("#start_number").html(firstThreadNumber)
      
      lastThreadNumber = currentPage * 50
      if lastThreadNumber > parseInt(numThreads)
        lastThreadNumber = numThreads
      @$el.find("#end_number").html(lastThreadNumber)
    else if attempt < TuringEmailApp.Views.ToolbarView.MAX_RETRY_ATTEMPTS
      setTimeout(
        =>
          @updatePaginationText(folderID, attempt + 1)
        500
      )

  #############################
  ### TuringEmailApp Events ###
  #############################

  currentEmailFolderChanged: (app, emailFolderID) ->
    @updateTitle emailFolderID
    @updatePaginationText emailFolderID

  emailFoldersChanged: (app) ->
    @render()
