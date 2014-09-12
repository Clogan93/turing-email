class TuringEmailApp.Views.ToolbarView extends Backbone.View
  template: JST["backbone/templates/toolbar_view"]
  tagName: "div"

  remove: ->
    @$el.remove()

  setup_toolbar_buttons: ->
    @setup_read()
    @setup_unread()
    @setup_trash()
    @setup_go_left()
    @setup_go_right()

  setup_read: ->
    @$el.find("i.fa-eye").parent().click ->
      checkedUIDs = []
      checked_checkboxes = $(".check-mail .checked")
      links_of_checked_emails = checked_checkboxes.parent().parent().find('a[href^="#email_thread"]')
      links_of_checked_emails.each ->
        link_components = $(@).attr("href").split("#")
        uid = link_components[link_components.length - 1]
        checkedUIDs.push uid
      checkedUIDs = _.uniq(checkedUIDs)
      TuringEmailApp.emailThreads.setSeen checkedUIDs

      #Alter classes
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.removeClass("unread")
      tr_element.addClass("read")
      checked_checkboxes.each ->
        $(@).removeClass("checked")

  setup_unread: ->
    @$el.find("i.fa-eye-slash").parent().click ->
      checkedUIDs = []
      checked_checkboxes = $(".check-mail .checked")
      links_of_checked_emails = checked_checkboxes.parent().parent().find('a[href^="#email_thread"]')
      links_of_checked_emails.each ->
        link_components = $(@).attr("href").split("#")
        uid = link_components[link_components.length - 1]
        checkedUIDs.push uid
      checkedUIDs = _.uniq(checkedUIDs)
      TuringEmailApp.emailThreads.setUnseen checkedUIDs

      #Alter classes
      tr_element = $(".check-mail .checked").parent().parent()
      tr_element.removeClass("read")
      tr_element.addClass("unread")
      checked_checkboxes.each ->
        $(@).removeClass("checked")

  setup_trash: ->
    @$el.find("i.fa-trash-o").parent().click ->
      console.log "trash"

  setup_go_left: ->
    @$el.find("#paginate_left_link").click ->
      windowSearchAttribute = window.location.search
      if windowSearchAttribute != ""
        currentPageNumber = windowSearchAttribute.split("page=")[1]
        newPageNumber = parseInt(currentPageNumber) - 1
        if newPageNumber >= 1
          newUrl = "?page=" + newPageNumber.toString()
          window.location = newUrl

    @$el.find("#paginate_left_link").click ->
      console.log window.location.search
      if windowSearchAttribute != ""
        currentPageNumber = windowSearchAttribute.split("page=")[1]
      else
        currentPageNumber = "1"
      newPageNumber = parseInt(currentPageNumber) + 1
      newUrl = "?page=" + newPageNumber.toString()
      window.location = newUrl

  setup_go_right: ->
    @$el.find("#paginate_right_link").click ->
      windowSearchAttribute = window.location.search
      if windowSearchAttribute != ""
        currentPageNumber = windowSearchAttribute.split("page=")[1]
      else
        currentPageNumber = "1"
      newPageNumber = parseInt(currentPageNumber) + 1
      newUrl = "?page=" + newPageNumber.toString()
      console.log newUrl
      window.location = newUrl

  render: ->
    @$el.html(@template())
    @setup_toolbar_buttons()
    return this
