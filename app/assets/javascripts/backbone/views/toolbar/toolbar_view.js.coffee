class TuringEmailApp.Views.ToolbarView extends Backbone.View
  @MAX_RETRY_ATTEMPTS: 5

  template: JST["backbone/templates/toolbar/toolbar"]
  tagName: "div"

  initialize: (options) ->
    @app = options.app
    @currentEmailFolders = options.emailFolders if options.emailFolders?
    @demoMode = if options.demoMode? then options.demoMode else true
    
    @listenTo(options.app, "change:currentEmailFolder", @currentEmailFolderChanged)
    @listenTo(options.app, "change:emailFolders", @emailFoldersChanged)

    @$el.addClass("mail-box-header")
    @$el.addClass("toolbar")

  render: ->
    emailFolders = @currentEmailFolders?.toJSON() ? []
    @$el.html(@template({emailFolders : emailFolders, demoMode: @demoMode}))
    
    emailFolders = _.sortBy(emailFolders, (emailFolder) ->
      emailFolder.name
    )

    @setupAllCheckbox()
    @divAllCheckbox = @$el.find("div.icheckbox_square-green")
    
    @setupButtons()
    @setupDemoModeSwitch()
    @renderReportToolbarDropdown()

    if @currentEmailFolder?
      @updatePaginationText(@currentEmailFolder, @currentEmailFolderPage)

    $(".tooltip").remove()

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
      @trigger("readClicked", this)

    @$el.find(".mark_as_unread").parent().click =>
      @trigger("unreadClicked", this)

    @$el.find("i.fa-archive").parent().click =>
      @$el.find("i.fa-archive").tooltip('hide')
      @trigger("archiveClicked", this)

    @$el.find("i.fa-trash-o").parent().click =>
      @$el.find("i.fa-trash-o").tooltip('hide')
      @trigger("trashClicked", this)

    @$el.find(".paginate-left-link").click =>
      @$el.find(".paginate-left-link").tooltip('hide')
      @trigger("leftArrowClicked", this)

    @$el.find(".paginate-right-link").click =>
      @$el.find(".paginate-right-link").tooltip('hide')
      @trigger("rightArrowClicked", this)

    $(window).resize =>
      if $(".mail-box-header.toolbar").width() < 525
        $(".current-emails-displayed-counter").hide()
      else
        $(".current-emails-displayed-counter").show()

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

    @$el.find(".refresh-button").click =>
      @$el.find(".refresh-button").tooltip('hide')
      @trigger("refreshClicked", this)

    @$el.find(".toolbar-elements, .pagination-buttons").tooltip
      selector: "[data-toggle=tooltip], .tooltip-button"
      container: "body"

    @$el.find(".settings-button").click ->
      $(this).tooltip('hide')

  setupDemoModeSwitch: ->
    @$el.find(".demo_mode_switch").bootstrapSwitch()

    @$el.find(".demo_mode_switch").on "switch-change", (event, state) =>
      @demoMode = !@demoMode
      @trigger("demoModeSwitchClicked", @demoMode)
      
  setupBulkActionButtons: ->
    @$el.find(".all-bulk-action").click =>
      @divAllCheckbox.iCheck("check")
      @trigger("checkAllClicked", this)

    @$el.find(".none-bulk-action").click =>
      @divAllCheckbox.iCheck("uncheck")
      @trigger("uncheckAllClicked", this)

    @$el.find(".read-bulk-action").click =>
      @trigger("checkAllReadClicked", this)

    @$el.find(".unread-bulk-action").click =>
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
      
      firstThreadNumber = if numThreads is 0 then 0 else (page - 1) * TuringEmailApp.Models.UserConfiguration.EmailThreadsPerPage + 1
      
      lastThreadNumber = page * TuringEmailApp.Models.UserConfiguration.EmailThreadsPerPage
      lastThreadNumber = numThreads if lastThreadNumber > parseInt(numThreads)
    else
      numThreads = 0
      firstThreadNumber = 0
      lastThreadNumber = 0

    @$el.find(".total-emails-number").html(numThreads)
    @$el.find(".start-number").html(firstThreadNumber)
    @$el.find(".end-number").html(lastThreadNumber)
    
  showMoveToFolderMenu: ->
    @$el.find(".move-to-folder-dropdown-menu").trigger("click.bs.dropdown")

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
