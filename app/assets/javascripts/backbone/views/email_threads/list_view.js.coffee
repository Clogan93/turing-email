TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListView extends Backbone.View
  initialize: ->
    @listenTo(@collection, "add", @addOne)
    @listenTo(@collection, "remove", @removeOne)
    @listenTo(@collection, "reset", @resetView)
    @listenTo(@collection, "destroy", @remove)

    @listenTo(TuringEmailApp, 'change:toolbarView', @toolbarViewChanged)
    @listenTo(TuringEmailApp, 'change:currentEmailThread', @currentEmailThreadChanged)

    @toolbarViewChanged(TuringEmailApp, TuringEmailApp.views.toolbarView) if TuringEmailApp.views.toolbarView?

  render: ->
    @removeAll()
    @$el.empty()
    @listItemViews = {}
    
    @addAll()

    @setupSplitPaneResizing()
    @setupKeyboardShortcuts()

    @moveTuringEmailReportToTop()

    return this

  resetView: (models, options) ->
    @removeAll(options.previousModels) if options?.previousModels?
    
    @render()
    
  addOne: (emailThread) ->
    @listItemViews ?= {}

    listItemView = new TuringEmailApp.Views.EmailThreads.ListItemView(model: emailThread)
    @$el.append(listItemView.render().el)
    listItemView.addedToDOM()
    
    @listenTo(listItemView, "click", @listItemClicked)
    @listItemViews[emailThread.get("uid")] = listItemView

  removeOne: (emailThread) ->
    listItemView = @listItemViews?[emailThread.get("uid")]
    return if not listItemView
    
    @stopListening(listItemView)
    listItemView.remove()

    delete @listItemViews[emailThread.get("uid")]
    
  addAll: ->
    @collection.forEach(@addOne, this)

  removeAll: (models = @collection.models) ->
    models.forEach(@removeOne, this)
    
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

  #############################
  ### TuringEmailApp Events ###
  #############################      
      
  toolbarViewChanged: (app, toolbarView) ->
    @stopListening(@currentToolbarView) if @currentToolbarView?
    @currentToolbarView = toolbarView
    
    @listenTo(@currentToolbarView, "selectAll", @selectAll)
    @listenTo(@currentToolbarView, "selectAllRead", @selectAllRead)
    @listenTo(@currentToolbarView, "selectAllUnread", @selectAllUnread)
    @listenTo(@currentToolbarView, "deselectAll", @deselectAll)
    
  currentEmailThreadChanged: (app, emailThread) ->
    if @currentlySelectedEmailThread
      listItemView = @listItemViews[@currentlySelectedEmailThread.get("uid")]
      listItemView?.unhighlight()
      listItemView?.markRead()

    listItemView = @listItemViews[emailThread.get("uid")]
    listItemView?.highlight()
    @deselectAll()

    @currentlySelectedEmailThread = TuringEmailApp.currentEmailThread

  ######################
  ### Toolbar Events ###
  ######################
  
  selectAll: ->
    listItemView.select() for listItemView in _.values(@listItemViews)
      
  selectAllRead: ->
    @collection.forEach(
      (emailThread) ->
        seen = emailThread.get("emails")[0].seen
        listItemView = @listItemViews[emailThread.get("uid")]
        if seen then listItemView.select() else listItemView.deselect()
      , this)

  selectAllUnread: ->
    @collection.forEach(
      (emailThread) ->
        seen = emailThread.get("emails")[0].seen
        listItemView = @listItemViews[emailThread.get("uid")]
        if !seen then listItemView.select() else listItemView.deselect()
    , this)
      
  deselectAll: ->
    listItemView.deselect() for listItemView in _.values(@listItemViews)

  ###########################
  ### ListItemView Events ###
  ###########################
  
  listItemClicked: (listItemView) ->
    isDraft = listItemView.model.get("emails")[0].draft_id?
    emailThreadUID = listItemView.model.get("uid")

    if isDraft
      TuringEmailApp.routers.emailThreadsRouter.showEmailDraft emailThreadUID
    else
      listItemView.markRead
      TuringEmailApp.views.toolbarView.decrementUnreadCountOfCurrentFolder(TuringEmailApp.currentFolderId)

      TuringEmailApp.routers.emailThreadsRouter.showEmailThread emailThreadUID
      