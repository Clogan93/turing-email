class TuringEmailApp.Views.ToolbarView extends Backbone.View
  template: JST["backbone/templates/toolbar_view"]
  tagName: "div"

  remove: ->
    @$el.remove()

  decrementUnreadCountOfCurrentFolder: (folder_id) ->
    currentFolder = TuringEmailApp.emailFolders.getEmailFolder(folder_id)
    currentFolder.set("num_unread_threads", currentFolder.get("num_unread_threads") - 1)
    @$el.find(".label_count_badge").html(currentFolder.get("num_unread_threads")) if currentFolder?
    if folder_id is "INBOX"
      $(".inbox_count_badge").html(currentFolder.get("num_unread_threads")) if currentFolder?

  renderLabelTitleAndUnreadCount: (folder_id) ->
    currentFolder = TuringEmailApp.emailFolders.getEmailFolder(folder_id)
    @$el.find(".label_name").html(currentFolder.get("name")) if currentFolder?
    @$el.find(".label_count_badge").html(currentFolder.get("num_unread_threads")) if currentFolder?

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

  setupSearch: ->
    $("#search_input").change ->
      $("a#search_button_link").attr("href", "#search#" + $(@).val())

  retrieveCheckedUIDs: ->
    checkedUIDs = []
    links_of_checked_emails = $(".check-mail .checked").parent().parent().find('a[href^="#email_thread"]')
    links_of_checked_emails.each ->
      link_components = $(@).attr("href").split("#")
      uid = link_components[link_components.length - 1]
      checkedUIDs.push uid
    checkedUIDs = _.uniq(checkedUIDs)
    return checkedUIDs

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
      $(".check-mail .checked").each ->
        $(@).removeClass("checked")

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
      $(".check-mail .checked").each ->
        $(@).removeClass("checked")

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
      $(".check-mail .checked").each ->
        $(@).removeClass("checked")

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
      $(".check-mail .checked").each ->
        $(@).removeClass("checked")

  setupRead: ->
    @$el.find("i.fa-eye").parent().click =>
      checkedUIDs = @retrieveCheckedUIDs()
      TuringEmailApp.emailThreads.seenIs checkedUIDs, true

      #Alter UI
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.removeClass("unread")
      tr_element.addClass("read")
      $(".check-mail .checked").each ->
        $(@).removeClass("checked")

  setupUnread: ->
    @$el.find("i.fa-eye-slash").parent().click =>
      checkedUIDs = @retrieveCheckedUIDs()
      TuringEmailApp.emailThreads.seenIs checkedUIDs, false

      #Alter classes
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.removeClass("read")
      tr_element.addClass("unread")
      $(".check-mail .checked").each ->
        $(@).removeClass("checked")

  setupGoLeft: ->
    @$el.find("#paginate_left_link").click ->
      if window.location.href.indexOf("page=") != -1
        currentPageNumber = window.location.href.split("page=")[1]
      else
        currentPageNumber = "1"
      newPageNumber = parseInt(currentPageNumber) - 1
      if newPageNumber >= 1
        newQuery = "?page=" + newPageNumber.toString()
        if window.location.hash.indexOf("page=") then hashUrlComponent = window.location.hash.split("?page=")[0] else hashUrlComponent = window.location.hash
        window.location = window.location.origin + window.location.pathname + hashUrlComponent + newQuery

  setupGoRight: ->
    @$el.find("#paginate_right_link").click ->
      if TuringEmailApp.emailThreads.length is 50
        if window.location.href.indexOf("page=") != -1
          currentPageNumber = window.location.href.split("page=")[1]
        else
          currentPageNumber = "1"
        newPageNumber = parseInt(currentPageNumber) + 1
        newQuery = "?page=" + newPageNumber.toString()
        if window.location.hash.indexOf("page=") then hashUrlComponent = window.location.hash.split("?page=")[0] else hashUrlComponent = window.location.hash
        window.location = window.location.origin + window.location.pathname + hashUrlComponent + newQuery

  render: ->
    @$el.html(@template({'emailFolders' : @collection.toJSON()} ))
    @setupToolbarButtons()
    return this
