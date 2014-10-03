class TuringEmailApp.Views.ToolbarView extends Backbone.View
  @MAX_RETRY_ATTEMPTS: 5

  template: JST["backbone/templates/toolbar_view"]
  tagName: "div"

  initialize: (options) ->
    @app = options.app
    
    @listenTo(options.app, "change:currentEmailFolder", @currentEmailFolderChanged)
    @listenTo(options.app, "change:emailFolders", @emailFoldersChanged)
    @listenTo(options.app, "change:emailFolderUnreadCount", @emailFolderUnreadCountChanged)
  
  render: ->
    emailFolders = TuringEmailApp.collections.emailFolders?.toJSON() ? []
    @$el.html(@template({'emailFolders' : emailFolders}))
    
    @setupAllCheckbox()
    @divAllCheckbox = @$el.find("div.icheckbox_square-green")
    
    @setupButtons()
    
    return this

  #######################
  ### Setup Functions ###
  #######################

  setupAllCheckbox: ->
    @$el.find(".i-checks").iCheck
      checkboxClass: "icheckbox_square-green"
      radioClass: "iradio_square-green"

    @$el.find("div.icheckbox_square-green ins").click (event) =>
      if @allCheckboxIsChecked()
        @trigger("checkAllClicked", this)
      else
        @trigger("uncheckAllClicked", this)

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
      @divAllCheckbox.iCheck("check")
      @trigger("checkAllClicked", this)

    @$el.find("#none_bulk_action").click =>
      @divAllCheckbox.iCheck("uncheck")
      @trigger("uncheckAllClicked", this)

    @$el.find("#read_bulk_action").click =>
      @trigger("checkAllReadClicked", this)

    @$el.find("#unread_bulk_action").click =>
      @trigger("checkAllUnreadClicked", this)

  setupSearchButton: ->
    @$el.find("#search_input").change ->
      TuringEmailApp.views.toolbarView.$el.find("a#search_button_link").attr("href", "#search/" + $(@).val())

    @$el.find("#search_input").keypress (event) =>
      if event.which is 13
        event.preventDefault();
        @trigger("searchClicked", this, $(event.target).val())

  #################
  ### Functions ###
  #################

  allCheckboxIsChecked: ->
    return @divAllCheckbox.hasClass "checked"
    
  uncheckAllCheckbox: ->
    @divAllCheckbox.iCheck("uncheck")

  updateTitle: (emailFolderID, attempt=1) ->
    emailFolder = TuringEmailApp.collections.emailFolders.getEmailFolder(emailFolderID)
    
    if emailFolder?
      folderName = emailFolder.get("name")
      badgeString = emailFolder.badgeString()

      if badgeString is "" || badgeString is "0"
        badgeString = ""
      else
        badgeString = "(" + badgeString + ")"

      @$el.find("#title").html('<span class="label_name">' + folderName +
                               '</span> <span class="label_count_badge">' + badgeString + '</span>')
    else if attempt < TuringEmailApp.Views.ToolbarView.MAX_RETRY_ATTEMPTS
      setTimeout(
        =>
          @updateTitle(emailFolderID, attempt + 1)
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

  currentEmailFolderChanged: (app, emailFolder) ->
    return if not emailFolder?

    emailFolderID = emailFolder.get("label_id")
    
    @updateTitle emailFolderID
    @updatePaginationText emailFolderID

  emailFoldersChanged: (app) ->
    @render()

  # TODO write test
  emailFolderUnreadCountChanged: (app, emailFolder) ->
    @updateTitle(emailFolder.get("label_id"))
