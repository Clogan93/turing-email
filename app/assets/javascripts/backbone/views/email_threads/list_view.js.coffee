TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListView extends Backbone.View
  initialize: (options) ->
    @listenTo(@collection, "add", @addOne)
    @listenTo(@collection, "remove", @removeOne)
    @listenTo(@collection, "reset", @resetView)
    @listenTo(@collection, "destroy", @remove)

  render: ->
    @removeAll()
    @$el.empty()
    @listItemViews = {}
    
    @addAll()

    @setupSplitPaneResizing()
    @setupKeyboardShortcuts()

    @moveTuringEmailReportToTop()

    @select(@selectedItem(), silent: true) if @selectedItem()?

    return this

  resetView: (models, options) ->
    @removeAll(options.previousModels) if options?.previousModels?
    
    @render()

  ############################
  ### Collection Functions ###
  ############################

  addOne: (emailThread) ->
    @listItemViews ?= {}

    listItemView = new TuringEmailApp.Views.EmailThreads.ListItemView(model: emailThread)
    @$el.append(listItemView.render().el)
    listItemView.addedToDOM()

    @hookListItemViewEvents(listItemView)

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

  #######################
  ### Setup Functions ###
  #######################

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

  ###############
  ### Getters ###
  ###############
  
  selectedItem: ->
    if @selectedListItemView? then @selectedListItemView.model else null

  getCheckedListItemViews: ->
    checkedListItemViews = []

    for listItemView in _.values(@listItemViews)
      checkedListItemViews.push(listItemView) if listItemView.isChecked()

    return checkedListItemViews

  ###############
  ### Actions ###
  ###############

  moveTuringEmailReportToTop: ->
    trReportEmail = null

    @$el.find("td.mail-contact").each ->
      textValue = $(@).text().trim()

      if textValue is "Turing Email"
        trReportEmail = $(@).parent()

    if trReportEmail?
      trReportEmail.remove()
      $("#email_table_body").prepend(trReportEmail)

  select: (emailThread, options) ->
    listItemView = @listItemViews?[emailThread.get("uid")]
    listItemView?.select(options)
    
  deselect: () ->
    @selectedListItemView?.deselect()

  checkAll: ->
    listItemView.check() for listItemView in _.values(@listItemViews)


  checkAllRead: ->
    for listItemView in _.values(@listItemViews)
      seen = listItemView.model.get("emails")[0].seen
      if seen then listItemView.check() else listItemView.uncheck()

  checkAllUnread: ->
    for listItemView in _.values(@listItemViews)
      seen = listItemView.model.get("emails")[0].seen
      if !seen then listItemView.check() else listItemView.uncheck()

  uncheckAll: ->
    listItemView.uncheck() for listItemView in _.values(@listItemViews)

  markEmailThreadRead: (emailThread) ->
    @listItemViews[emailThread.get("uid")]?.markRead()
    
  markEmailThreadUnread: (emailThread) ->
    @listItemViews[emailThread.get("uid")]?.markUnread()

  markCheckedRead: ->
    for listItemView in _.values(@listItemViews)
      listItemView.markRead() if listItemView.isChecked()

  markCheckedUnread: ->
    for listItemView in _.values(@listItemViews)
      listItemView.markUnread() if listItemView.isChecked()

  ###########################
  ### ListItemView Events ###
  ###########################

  hookListItemViewEvents: (listItemView) ->
    @listenTo(listItemView, "click", (listItemView) =>
      @select(listItemView.model)
    )

    # TODO write tests
    @listenTo(listItemView, "selected", (listItemView) =>
      @selectedListItemView?.deselect()
      @uncheckAll()

      @selectedListItemView = listItemView
      @trigger("listItemSelected", this, listItemView)
    )

    # TODO write tests
    @listenTo(listItemView, "deselected", (listItemView) =>
      @selectedListItemView = null

      @trigger("listItemDeselected", this, listItemView)
    )

    # TODO write tests
    @listenTo(listItemView, "checked", (listItemView) =>
      @trigger("listItemChecked", this, listItemView)

      @selectedListItemView?.deselect()
    )

    # TODO write tests
    @listenTo(listItemView, "unchecked", (listItemView) =>
      @trigger("listItemUnchecked", this, listItemView)

      @selectedListItemView?.select()
    )