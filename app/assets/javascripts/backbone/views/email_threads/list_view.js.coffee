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

    @renderCheckboxes()
    
    @setupSplitPaneResizing()
    @setupListItemViewClicks()
    @setupKeyboardShortcuts()
    
    @moveTuringEmailReportToTop()
    
    if @collections?.length() > 0
      TuringEmailApp.currentEmailThreadIs(@collection.models[0].get("uid")) if TuringEmailApp.isSplitPaneMode()

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
      else
        TuringEmailApp.views.emailThreadsListView.checkboxCheckedValueIs $(@).parent(), false
      
  setupSplitPaneResizing: ->
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

  # this is here instead of in ListItemView as an optimization so it is only caled once. 
  setupListItemViewClicks: ->
    tds = @$el.find('td.check-mail, td.mail-contact, td.mail-subject, td.mail-date')
    tds.click (event) ->
      tr = $(@).parent()
      isDraft = tr.data("isDraft")
      emailThreadUID = tr.data("emailThreadUID")

      if isDraft
        TuringEmailApp.routers.emailThreadsRouter.showEmailDraft emailThreadUID
      else
        TuringEmailApp.views.emailThreadsListView.markRowRead tr
        TuringEmailApp.routers.emailThreadsRouter.showEmailThread emailThreadUID

  setupKeyboardShortcuts: ->
    $("#email_table_body tr:nth-child(1)").addClass("email_thread_highlight")
        
  moveTuringEmailReportToTop: ->
    trReportEmail = null
    
    @$el.find("td.mail-contact").each ->
      textValue = $(@).text()

      if textValue is "Turing Email"
        trReportEmail = $(@).parent()

    if trReportEmail?
      trReportEmail.remove()
      $("#email_table_body").prepend(trReportEmail)

  currentEmailThreadChanged: (emailThread) ->
    @unhighlightEmailThread(@currentlySelectedEmailThread) if @currentlySelectedEmailThread
    @highlightEmailThread(emailThread)
    @uncheckAllCheckboxes()

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

  highlightEmailThread: (emailThread) ->
    tr = @$el.find("tr[name=" + emailThread.get("uid") + "]")
    tr.removeClass("read")
    tr.removeClass("unread")
    tr.addClass("currently_being_read")

  unhighlightEmailThread: (emailThread) ->
    if emailThread?
      tr = @$el.find("tr[name=" + emailThread.get("uid") + "]")
      tr.removeClass("currently_being_read")
      tr.addClass("read")

  markRowRead: (tr) ->
    if tr.hasClass("unread")
      TuringEmailApp.views.toolbarView.decrementUnreadCountOfCurrentFolder(TuringEmailApp.currentFolderId)
      tr.removeClass("unread")
      tr.addClass("read")
