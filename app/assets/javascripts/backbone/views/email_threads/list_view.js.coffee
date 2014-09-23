TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListView extends Backbone.View
  initialize: ->
    @listenTo(@collection, "add", @addOne)
    @listenTo(@collection, "reset", @addAll)
    @listenTo(@collection, "destroy", @remove)

    @listenTo(TuringEmailApp, 'currentEmailThreadChanged', @currentEmailThreadChanged);

  remove: ->
    @$el.remove()

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

    @setupTdClicksOfLinks()

    @currentlySelectedEmailThread = @collection.models[0]
    @highlightEmailThread @currentlySelectedEmailThread

    if TuringEmailApp.models.userSettings.get("split_pane_mode") is "horizontal"
      $("#preview_panel").show()
      @renderEmailPreview(@currentlySelectedEmailThread)

  currentEmailThreadChanged: ->
    @unhighlightEmailThread @currentlySelectedEmailThread
    @highlightEmailThread TuringEmailApp.currentEmailThread
    @currentlySelectedEmailThread = TuringEmailApp.currentEmailThread

    if TuringEmailApp.isSplitPaneMode()
      $("#preview_panel").show()
      emailThreadViewEl = "#preview_content"
    else
      emailThreadViewEl = "#email_table_body"
      $("#email-folder-mail-header").hide()

    emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: TuringEmailApp.currentEmailThread
      el: $(emailThreadViewEl)
    )
    emailThreadView.render()

    TuringEmailApp.views.previewEmailThreadView = emailThreadView if TuringEmailApp.isSplitPaneMode()

  renderCheckboxes: ->
    $(".i-checks").iCheck
      checkboxClass: "icheckbox_square-green"
      radioClass: "iradio_square-green"

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

  renderEmailPreview: (emailThread) ->
    TuringEmailApp.currentEmailThreadIs emailThread
    TuringEmailApp.views.previewEmailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: TuringEmailApp.currentEmailThread
      el: $("#preview_content")
    )
    TuringEmailApp.views.previewEmailThreadView.render()

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
      currentFolderId = TuringEmailApp.currentFolderId
      TuringEmailApp.views.toolbarView.decrementUnreadCountOfCurrentFolder(currentFolderId)
    aTag.parent().parent().removeClass("unread")
    aTag.parent().parent().addClass("read")

  setupTdClicksOfLinks: ->
    tds = @$el.find('td.mail-ontact, td.mail-subject, td.mail-date')
    tds.click ->
      aTag = $(@).find('a[href^="#email_thread"]').first()
      TuringEmailApp.views.emailThreadsListView.updateToMarkAsRead aTag
      link_components = aTag.attr("href").split("#")
      uid = link_components[link_components.length - 1]
      TuringEmailApp.routers.emailThreadsRouter.showEmailThread uid
