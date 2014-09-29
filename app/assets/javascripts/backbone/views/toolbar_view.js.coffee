class TuringEmailApp.Views.ToolbarView extends Backbone.View
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

    @$el.find("i.fa-eye").parent().click =>
      @trigger("readClicked", this)

    @$el.find("i.fa-eye-slash").parent().click =>
      @trigger("unreadClicked", this)

    @$el.find("i.fa-archive").parent().click =>
      @trigger("archiveClicked", this)

    @$el.find("i.fa-trash-o").parent().click =>
      @trigger("trashClicked", this)

    @setupGoLeftButton()
    @setupGoRightButton()
    @setupLabelAsLinksButton()
    @setupMoveToFolderButton()
    @setupSearchButton()
    @setupRefreshButton()

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

  setupGoLeftButton: ->
    @$el.find("#paginate_left_link").click ->
      TuringEmailApp.collections.emailThreads.previousPage()

  setupGoRightButton: ->
    @$el.find("#paginate_right_link").click ->
      if TuringEmailApp.collections.emailThreads.length is 50
        TuringEmailApp.collections.emailThreads.nextPage()

  setupLabelAsLinksButton: ->
    @$el.find(".label_as_link").click (event) =>
      checkedUIDs = @retrieveCheckedUIDs()
      postData = {}
      postData.email_thread_uids = checkedUIDs
      postData.gmail_label_name = $(event.target).text()

      url = "/api/v1/email_threads/apply_gmail_label.json"
      $.ajax
        type: "POST"
        url: url
        data: postData

      #Alter UI
      @trigger("deselectAll")

  setupMoveToFolderButton: ->
    @$el.find(".move_to_folder_link").click (event) =>
      checkedUIDs = @retrieveCheckedUIDs()
      postData = {}
      postData.email_thread_uids = checkedUIDs
      postData.email_folder_name = $(event.target).text()

      url = "/api/v1/email_threads/move_to_folder.json"
      $.post url, postData

      #Alter UI
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.remove()

      @trigger("deselectAll")

  setupSearchButton: ->
    $("#search_input").change ->
      $("a#search_button_link").attr("href", "#search/" + $(@).val())
    $("#search_input").keypress (e) ->
      if e.which is 13
        TuringEmailApp.routers.searchResultsRouter.showSearchResultsRouter $(@).val()
      return

    $("#top-search-form").submit ->
      TuringEmailApp.routers.searchResultsRouter.showSearchResultsRouter $(@).find("input").val()
      return false

  setupRefreshButton: ->
    @$el.find("#refresh_button").click ->
      TuringEmailApp.collections.emailThreads.fetch()
        
  #############################
  ### TuringEmailApp Events ###
  #############################

  currentEmailFolderChanged: (app, emailFolderID) ->
    @renderLabelTitleAndUnreadCount emailFolderID
    @renderEmailsDisplayedCounter emailFolderID

  emailFoldersChanged: (app) ->
    @render()

  selectAllIsChecked: ->
    return @divSelectAllICheck.hasClass "checked"
    
  deselectAllCheckbox: ->
    @divSelectAllICheck.iCheck("uncheck")
    
  retrieveCheckedUIDs: ->
    checkedUIDs = []
    
    links_of_checked_emails = $(".check-mail .checked").parent().parent().find('a[href^="#email_thread"]')
    links_of_checked_emails.each ->
      link_components = $(@).attr("href").split("/")
      uid = link_components[link_components.length - 1]
      checkedUIDs.push uid
    
    checkedUIDs = _.uniq(checkedUIDs)
    return checkedUIDs

  decrementUnreadCountOfCurrentFolder: (folderID) ->
    currentFolder = TuringEmailApp.collections.emailFolders.getEmailFolder(folderID)

    if currentFolder?
      currentFolder.set("num_unread_threads", currentFolder.get("num_unread_threads") - 1)
      
      if folderID is "INBOX"
        $(".inbox_count_badge").html(currentFolder.get("num_unread_threads"))
      else
        @$el.find(".label_count_badge").html(currentFolder.get("num_unread_threads"))

  renderLabelTitleAndUnreadCount: (folderID) ->
    currentFolder = TuringEmailApp.collections.emailFolders.getEmailFolder(folderID)
    if currentFolder?
      console.log currentFolder.get("name")
      @$el.find(".label_name").html(currentFolder.get("name"))
      if currentFolder.get("label_id") is "DRAFT"
        @$el.find(".label_count_badge").html(currentFolder.get("num_threads"))
      else
        @$el.find(".label_count_badge").html(currentFolder.get("num_unread_threads"))

  renderEmailsDisplayedCounter: (folderID) ->
    currentFolder = TuringEmailApp.collections.emailFolders.getEmailFolder(folderID)
    if currentFolder?
      num_threads = currentFolder.get("num_threads")
      @$el.find("#total_emails_number").html(num_threads)
      number_of_pages = parseInt(TuringEmailApp.collections.emailThreads.page)
      start_number = (number_of_pages - 1) * 50 + 1
      @$el.find("#start_number").html(start_number)
      end_number = number_of_pages * 50
      if end_number > parseInt(num_threads)
        end_number = num_threads
      @$el.find("#end_number").html(end_number)
