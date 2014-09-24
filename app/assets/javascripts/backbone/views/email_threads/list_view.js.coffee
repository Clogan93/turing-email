TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListView extends Backbone.View
  initialize: ->
    @listenTo(@collection, "add", @addOne)
    @listenTo(@collection, "reset", @addAll)
    @listenTo(@collection, "destroy", @remove)

    @listenTo(TuringEmailApp, 'change:currentEmailThread', @currentEmailThreadChanged)

  render: ->
    @addAll()
    return this

  addOne: (thread) ->
    listItemView = new TuringEmailApp.Views.EmailThreads.ListItemView(model: thread)
    @$el.append(listItemView.render().el)

  addAll: ->
    @$el.empty()
    @collection.forEach(@addOne, this)
    @moveReportToTop()

    @renderCheckboxes()

    @addKeyboardShortcutHighlight()

    @setupReadUnreadRendering()

    @setupPreviewDragging()

    @setupTdClicksOfLinks()

    if @collections?.length() > 0
      TuringEmailApp.currentEmailThreadIs(@collection.models[0].get("uid")) if TuringEmailApp.isSplitPaneMode()

  currentEmailThreadChanged: ->
    @unhighlightEmailThread @currentlySelectedEmailThread
    @highlightEmailThread TuringEmailApp.currentEmailThread
    @currentlySelectedEmailThread = TuringEmailApp.currentEmailThread

  checkboxCheckedValueIs: (checkbox, isChecked) ->
    if isChecked
      checkbox.iCheck("check")
      checkbox.parent().parent().addClass("checked_email_thread")
    else
      checkbox.iCheck("uncheck")
      checkbox.parent().parent().removeClass("checked_email_thread")

  checkAllCheckboxes: ->
    $("#email_table_body div.icheckbox_square-green").each ->
      TuringEmailApp.views.emailThreadsListView.checkboxCheckedValueIs $(@), true

  uncheckAllCheckboxes: ->
    $("#email_table_body div.icheckbox_square-green").each ->
      TuringEmailApp.views.emailThreadsListView.checkboxCheckedValueIs $(@), false
      $(@).iCheck("uncheck")

  renderCheckboxes: ->
    $(".i-checks").iCheck
      checkboxClass: "icheckbox_square-green"
      radioClass: "iradio_square-green"

    $("#bulk_action_checkbox_dropdown div.icheckbox_square-green ins").click ->
      if $(@).parent().hasClass "checked"
        TuringEmailApp.views.emailThreadsListView.checkAllCheckboxes()
      else
        TuringEmailApp.views.emailThreadsListView.uncheckAllCheckboxes()

    $("#email_table_body div.icheckbox_square-green ins").click ->
      if $(@).parent().hasClass "checked"
        TuringEmailApp.views.emailThreadsListView.checkboxCheckedValueIs $(@).parent(), true
        return false
      else
        TuringEmailApp.views.emailThreadsListView.checkboxCheckedValueIs $(@).parent(), false
        return false

  addKeyboardShortcutHighlight: ->
    $("#email_table_body tr:nth-child(1)").addClass("email_thread_highlight")

  moveReportToTop: ->
    report_email = null
    @$el.find("td.mail-contact a").each ->
      text_value = $(@).text()
      
      if text_value is "Turing Email"
        report_email = $(@).parent().parent()
    
    if report_email?
      report_email.remove()
      $("#email_table_body").prepend("<tr height='59px;' class='" + report_email.attr("class") + "'>" +
                                     report_email.html() + "</tr>")

  highlightEmailThread: (emailThread) ->
    aTag = @$el.find('a[href^="#email_thread#' + emailThread.get("uid") + '"]')
    aTag.parent().parent().removeClass("read")
    aTag.parent().parent().removeClass("unread")
    aTag.parent().parent().addClass("currently_being_read")

  unhighlightEmailThread: (emailThread) ->
    if emailThread?
      aTag = @$el.find('a[href^="#email_thread#' + emailThread.get("uid") + '"]')
      aTag.parent().parent().removeClass("currently_being_read")
      aTag.parent().parent().addClass("read")

  setupReadUnreadRendering: ->
    aTag = @$el.find('a[href^="#email_thread"]')
    aTag.click ->
      TuringEmailApp.views.emailThreadsListView.updateToMarkAsRead $(@)

  updateToMarkAsRead: (aTag) ->
    if aTag.parent().parent().hasClass("unread")
      TuringEmailApp.views.toolbarView.decrementUnreadCountOfCurrentFolder(TuringEmailApp.currentFolderId)

    aTag.parent().parent().removeClass("unread")
    aTag.parent().parent().addClass("read")

  setupTdClicksOfLinks: ->
    tds = @$el.find('td.mail-contact, td.mail-subject, td.mail-date')
    tds.click ->
      aTag = $(@).find('a[href^="#email_thread"]').first()
      if aTag.length > 0
        TuringEmailApp.views.emailThreadsListView.updateToMarkAsRead aTag
        link_components = aTag.attr("href").split("#")
        uid = link_components[link_components.length - 1]
        TuringEmailApp.routers.emailThreadsRouter.showEmailThread uid
      else
        aTag = $(@).find('a[href^="#email_draft"]').first()
        if aTag.length > 0
          link_components = aTag.attr("href").split("#")
          uid = link_components[link_components.length - 1]
          TuringEmailApp.routers.emailThreadsRouter.showEmailDraft uid

  setupPreviewDragging: ->
    return
    # if TuringEmailApp.isSplitPaneMode()
    #   $("#resize_border").mousedown ->
    #     TuringEmailApp.mouseStart = null
    #     $(document).mousemove (event) ->
    #       if !TuringEmailApp.mouseStart?
    #         TuringEmailApp.mouseStart = event.pageY
    #       if event.pageY - TuringEmailApp.mouseStart > 100
    #         $("#preview_panel").height("30%")
    #         TuringEmailApp.mouseStart = null
    #       return

    #     $(document).one "mouseup", ->
    #       $(document).unbind "mousemove"
