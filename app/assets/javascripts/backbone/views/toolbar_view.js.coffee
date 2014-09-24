class TuringEmailApp.Views.ToolbarView extends Backbone.View
  template: JST["backbone/templates/toolbar_view"]
  tagName: "div"

  render: ->
    @$el.html(@template({'emailFolders' : @collection.toJSON()} ))
    @setupToolbarButtons()
    return this

  retrieveCheckedUIDs: ->
    checkedUIDs = []
    
    links_of_checked_emails = $(".check-mail .checked").parent().parent().find('a[href^="#email_thread"]')
    links_of_checked_emails.each ->
      link_components = $(@).attr("href").split("#")
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
      @$el.find(".label_name").html(currentFolder.get("name"))
      @$el.find(".label_count_badge").html(currentFolder.get("num_threads"))

  setupToolbarButtons: ->
    @setupRead()
    @setupUnread()
    @setupArchive()
    @setupDelete()
    @setupGoLeft()
    @setupGoRight()
    @setupLabelAsLinks()
    @setupMoveToFolder()
    @setupSearch()
    @setupRefresh()
    @setupBulkActions()
    
  clearSelectedItems: ->
    $(".check-mail .checked").each ->
      $(@).removeClass("checked")

  setupBulkActions: ->
    @$el.find("#all_bulk_action").click =>
      @$el.find("#bulk_action_checkbox_dropdown div.icheckbox_square-green").addClass("checked")
      TuringEmailApp.views.emailThreadsListView.checkAllCheckboxes()

    @$el.find("#none_bulk_action").click =>
      @$el.find("#bulk_action_checkbox_dropdown div.icheckbox_square-green").removeClass("checked")
      TuringEmailApp.views.emailThreadsListView.uncheckAllCheckboxes()

    @$el.find("#read_bulk_action").click =>
      $("#email_table_body tr.read div.icheckbox_square-green, #email_table_body tr.currently_being_read div.icheckbox_square-green").each ->
        $(@).addClass("checked")
      $("#email_table_body tr.unread div.icheckbox_square-green").each ->
        $(@).removeClass("checked")

    @$el.find("#unread_bulk_action").click =>
      $("#email_table_body tr.read div.icheckbox_square-green, #email_table_body tr.currently_being_read div.icheckbox_square-green").each ->
        $(@).removeClass("checked")
      $("#email_table_body tr.unread div.icheckbox_square-green").each ->
        $(@).addClass("checked")

  setupRead: ->
    @$el.find("i.fa-eye").parent().click =>
      checkedUIDs = @retrieveCheckedUIDs()
      TuringEmailApp.collections.emailThreads.seenIs checkedUIDs, true

      #Alter UI
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.removeClass("unread")
      tr_element.addClass("read")
      
      @clearSelectedItems()

  setupUnread: ->
    @$el.find("i.fa-eye-slash").parent().click =>
      checkedUIDs = @retrieveCheckedUIDs()
      TuringEmailApp.collections.emailThreads.seenIs checkedUIDs, false

      #Alter classes
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.removeClass("read")
      tr_element.addClass("unread")

      @clearSelectedItems()

  setupArchive: ->
    @$el.find("i.fa-archive").parent().click =>
      checkedUIDs = @retrieveCheckedUIDs()

      postData = {}
      postData.email_thread_uids = checkedUIDs
      if window.location.hash is ""
        postData.email_folder_id = "INBOX"
      else
        url_components = window.location.hash.split("#")
        folder_id = url_components[url_components.length - 1]
        postData.email_folder_id = folder_id

      url = "/api/v1/email_threads/remove_from_folder.json"
      $.ajax
        type: "POST"
        url: url
        data: postData
        success: (data) ->
          return
        error: (data) ->
          TuringEmailApp.tattletale.log(JSON.stringify(data))
          TuringEmailApp.tattletale.send()

      #Alter UI
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.remove()

      @clearSelectedItems()

  setupDelete: ->
    @$el.find("i.fa-trash-o").parent().click =>
      checkedUIDs = @retrieveCheckedUIDs()

      postData = {}
      postData.email_thread_uids = checkedUIDs

      url = "/api/v1/email_threads/trash.json"
      $.ajax
        type: "POST"
        url: url
        data: postData
        success: (data) ->
          return
        error: (data) ->
          TuringEmailApp.tattletale.log(JSON.stringify(data))
          TuringEmailApp.tattletale.send()

      #Alter UI
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.remove()

      @clearSelectedItems()

  setupGoLeft: ->
    @$el.find("#paginate_left_link").click ->
      TuringEmailApp.collections.emailThreads.previousPage()

  setupGoRight: ->
    @$el.find("#paginate_right_link").click ->
      if TuringEmailApp.collections.emailThreads.length is 50
        TuringEmailApp.collections.emailThreads.nextPage()

  setupLabelAsLinks: ->
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
        success: (data) ->
          return
        error: (data) ->
          TuringEmailApp.tattletale.log(JSON.stringify(data))
          TuringEmailApp.tattletale.send()

      #Alter UI
      @clearSelectedItems()

  setupMoveToFolder: ->
    @$el.find(".move_to_folder_link").click (event) =>
      checkedUIDs = @retrieveCheckedUIDs()
      postData = {}
      postData.email_thread_uids = checkedUIDs
      postData.email_folder_name = $(event.target).text()

      url = "/api/v1/email_threads/move_to_folder.json"
      $.ajax
        type: "POST"
        url: url
        data: postData
        success: (data) ->
          return
        error: (data) ->
          TuringEmailApp.tattletale.log(JSON.stringify(data))
          TuringEmailApp.tattletale.send()

      #Alter UI
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.remove()

      @clearSelectedItems()

  setupSearch: ->
    $("#search_input").change ->
      $("a#search_button_link").attr("href", "#search#" + $(@).val())
    $("#search_input").keypress (e) ->
      if e.which is 13
        TuringEmailApp.routers.searchResultsRouter.showSearchResultsRouter $(@).val()
      return

    $("#top-search-form").submit ->
      TuringEmailApp.routers.searchResultsRouter.showSearchResultsRouter $(@).find("input").val()
      return false

  setupRefresh: ->
    @$el.find("#refresh_button").click ->
      TuringEmailApp.collections.emailThreads.fetch(
        success: (collection, response, options) =>
          TuringEmailApp.views.emailThreadsListView.renderCheckboxes()
      )
