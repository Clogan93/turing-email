class TuringEmailApp.Views.ToolbarView extends Backbone.View
  @MAX_RETRY_ATTEMPTS: 5

  template: JST["backbone/templates/toolbar/toolbar"]
  tagName: "div"

  initialize: (options) ->
    @app = options.app
    @currentEmailFolders = options.emailFolders if options.emailFolders?
    
    @listenTo(options.app, "change:currentEmailFolder", @currentEmailFolderChanged)
    @listenTo(options.app, "change:emailFolders", @emailFoldersChanged)

    @$el.addClass("mail-box-header")
    @$el.addClass("toolbar")
  
  render: ->
    emailFolders = @currentEmailFolders?.toJSON() ? []
    @$el.html(@template({'emailFolders' : emailFolders}))
    
    @setupAllCheckbox()
    @divAllCheckbox = @$el.find("div.icheckbox_square-green")
    
    @setupButtons()
    @renderReportToolbarDropdown()

    if @currentEmailFolder?
      @updatePaginationText(@currentEmailFolder, @currentEmailFolderPage)
    
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

    @$el.find(".mark_as_read").parent().click =>
      @$el.find(".mark_as_read").tooltip('hide')
      @trigger("readClicked", this)

    @$el.find(".mark_as_unread").parent().click =>
      @$el.find(".mark_as_unread").tooltip('hide')
      @trigger("unreadClicked", this)

    @$el.find("i.fa-archive").parent().click =>
      @$el.find("i.fa-archive").tooltip('hide')
      @trigger("archiveClicked", this)

    @$el.find("i.fa-trash-o").parent().click =>
      @$el.find("i.fa-trash-o").tooltip('hide')
      @trigger("trashClicked", this)

    @$el.find("#paginate_left_link").click =>
      @$el.find("#paginate_left_link").tooltip('hide')
      @trigger("leftArrowClicked", this)

    @$el.find("#paginate_right_link").click =>
      @$el.find("#paginate_left_link").tooltip('hide')
      @trigger("rightArrowClicked", this)

    $(window).resize =>
      if $(".mail-box-header.toolbar").width() < 525
        $(".current_emails_displayed_counter").hide()
      else
        $(".current_emails_displayed_counter").show()

    @$el.find(".label_as_link").click (event) =>
      @$el.find(".label_as_link").tooltip('hide')
      @trigger("labelAsClicked", this, $(event.target).attr("name"))

    @$el.find(".createNewLabel").click =>
      @$el.find(".createNewLabel").tooltip('hide')
      @trigger("createNewLabelClicked", this)

    @$el.find(".move_to_folder_link").click (event) =>
      @$el.find(".move_to_folder_link").tooltip('hide')
      @trigger("moveToFolderClicked", this, $(event.target).attr("name"))

    @$el.find(".createNewEmailFolder").click =>
      @$el.find(".createNewEmailFolder").tooltip('hide')
      @trigger("createNewEmailFolderClicked", this)

    @refreshToolbarButtonView = new TuringEmailApp.Views.RefreshToolbarButtonView(
      el: @$el.find(".refresh-button-placement")
    )
    @refreshToolbarButtonView.render()

    @$el.find("#refresh_button").click =>
      @$el.find("#refresh_button").tooltip('hide')
      @trigger("refreshClicked", this)

    @$el.find(".toolbar-elements, .pagination-buttons").tooltip
      selector: "[data-toggle=tooltip], .tooltip-button"
      container: "body"

    @$el.find(".settings-button").click ->
      $(this).tooltip('hide')

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

  #################
  ### Functions ###
  #################

  renderReportToolbarDropdown: ->
    @reportToolbarDropdown = new TuringEmailApp.Views.ReportToolbarDropdownView(
      el: @$el.find(".report_toolbar_dropdown")
    )
    @reportToolbarDropdown.render()

  allCheckboxIsChecked: ->
    return @divAllCheckbox.hasClass "checked"
    
  uncheckAllCheckbox: ->
    @divAllCheckbox?.iCheck("uncheck")

  updatePaginationText: (emailFolder, page) ->
    if emailFolder? && page?
      numThreads = emailFolder.get("num_threads")
      
      firstThreadNumber = if numThreads is 0 then 0 else (page - 1) * TuringEmailApp.Models.UserSettings.EmailThreadsPerPage + 1
      
      lastThreadNumber = page * TuringEmailApp.Models.UserSettings.EmailThreadsPerPage
      if lastThreadNumber > parseInt(numThreads)
        lastThreadNumber = numThreads
    else
      numThreads = 0
      firstThreadNumber = 0
      lastThreadNumber = 0

    @$el.find("#total_emails_number").html(numThreads)
    @$el.find("#start_number").html(firstThreadNumber)
    @$el.find("#end_number").html(lastThreadNumber)
    
  showMoveToFolderMenu: ->
    @$el.find("#moveToFolderDropdownMenu").trigger("click.bs.dropdown")

  #############################
  ### TuringEmailApp Events ###
  #############################

  currentEmailFolderChanged: (app, emailFolder, page) ->
    @currentEmailFolder = emailFolder
    @currentEmailFolderPage = page    

    @updatePaginationText(emailFolder, page)

  emailFoldersChanged: (app, emailFolders) ->
    @currentEmailFolders = emailFolders
    @render()
