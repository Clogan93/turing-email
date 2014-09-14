class TuringEmailApp.Views.ToolbarView extends Backbone.View
  template: JST["backbone/templates/toolbar_view"]
  tagName: "div"

  remove: ->
    @$el.remove()

  setup_toolbar_buttons: ->
    @setupRead()
    @setupUnread()
    @setupArchive()
    @setupDelete()
    @setupGoLeft()
    @setupGoRight()
    @setupLabelAsLinks()

  retrieveCheckedUIDs: ->
    checkedUIDs = []
    links_of_checked_emails = $(".check-mail .checked").parent().parent().find('a[href^="#email_thread"]')
    links_of_checked_emails.each ->
      link_components = $(@).attr("href").split("#")
      uid = link_components[link_components.length - 1]
      checkedUIDs.push uid
    checkedUIDs = _.uniq(checkedUIDs)
    return checkedUIDs

  setupLabelAsLinks: ->
    @$el.find(".label_as_link").click ->
      checkedUIDs = @retrieveCheckedUIDs()
      console.log "Label as link clicked"
      console.log checkedUIDs

      postData = {}
      postData.email_thread_uids = checkedUIDs

      url = "/api/v1/email_threads/apply_gmail_label"
      $.ajax
        type: "POST"
        url: url
        data: postData
        success: (data) ->
          return

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

      #Alter UI
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.remove()
      $(".check-mail .checked").each ->
        $(@).removeClass("checked")

  setupRead: ->
    @$el.find("i.fa-eye").parent().click =>
      checkedUIDs = @retrieveCheckedUIDs()
      TuringEmailApp.emailThreads.setSeen checkedUIDs

      #Alter UI
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.removeClass("unread")
      tr_element.addClass("read")
      $(".check-mail .checked").each ->
        $(@).removeClass("checked")

  setupUnread: ->
    @$el.find("i.fa-eye-slash").parent().click =>
      checkedUIDs = @retrieveCheckedUIDs()
      TuringEmailApp.emailThreads.setUnseen checkedUIDs

      #Alter classes
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.removeClass("read")
      tr_element.addClass("unread")
      $(".check-mail .checked").each ->
        $(@).removeClass("checked")

  setupGoLeft: ->
    @$el.find("#paginate_left_link").click ->
      windowSearchAttribute = window.location.search
      if windowSearchAttribute != ""
        currentPageNumber = windowSearchAttribute.split("page=")[1]
      else
        currentPageNumber = "1"
      newPageNumber = parseInt(currentPageNumber) - 1
      if newPageNumber >= 1
        newQuery = "?page=" + newPageNumber.toString()
        window.location = window.location.origin + window.location.pathname + window.location.hash + newQuery

  setupGoRight: ->
    @$el.find("#paginate_right_link").click ->
      if TuringEmailApp.emailThreads.length is 50
        windowSearchAttribute = window.location.search
        if windowSearchAttribute != ""
          currentPageNumber = windowSearchAttribute.split("page=")[1]
        else
          currentPageNumber = "1"
        newPageNumber = parseInt(currentPageNumber) + 1
        newQuery = "?page=" + newPageNumber.toString()
        window.location = window.location.origin + window.location.pathname + window.location.hash + newQuery

  render: ->
    @$el.html(@template({'emailFolders' : @collection.toJSON()} ))
    @setup_toolbar_buttons()
    return this
