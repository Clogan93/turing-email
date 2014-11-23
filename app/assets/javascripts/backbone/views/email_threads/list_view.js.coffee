TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListView extends Backbone.View
  initialize: (options) ->
    @listenTo(@collection, "add", @addOne)
    @listenTo(@collection, "remove", @removeOne)
    @listenTo(@collection, "reset", @resetView)
    @listenTo(@collection, "destroy", @remove)

  render: ->
    return if @skipRender

    startTime = Date.now()
    
    @removeAll()
    @$el.empty()
    @listItemViews = {}

    @$el.hide()
    frag = $(document.createDocumentFragment())
    @addAll(frag)
    @$el.append(frag)
    @$el.show()

    @select(@selectedItem(), silent: true) if @selectedItem()?
    
    console.log("EmailThreads.ListView render took " + (Date.now() - startTime) / 1000 + " seconds")

    return this

  resetView: (models, options) ->
    @removeAll(options.previousModels) if options?.previousModels?
    @select(@selectedItem(), silent: true) if @selectedItem()?

    @render()

  ############################
  ### Collection Functions ###
  ############################

  addOne: (emailThread, collection, options) ->
    @listItemViews ?= {}

    listItemView = new TuringEmailApp.Views.EmailThreads.ListItemView(model: emailThread)
    if options?.frag?
      options.frag.append(listItemView.render().el)
    else
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

  addAll: (frag) ->
    @collection.forEach(
      (emailThread) =>
        @addOne(emailThread, @collection, frag: frag)
    )

  removeAll: (models = @collection.models) ->
    @$el.empty()
    models.forEach(@removeOne, this)

  ###############
  ### Getters ###
  ###############
  
  selectedItem: ->
    if @selectedListItemView? then @selectedListItemView.model else null

  selectedIndex: ->
    return _.indexOf(_.values(@listItemViews), @selectedListItemView)

  getCheckedListItemViews: ->
    checkedListItemViews = []

    for listItemView in _.values(@listItemViews)
      checkedListItemViews.push(listItemView) if listItemView.isChecked()

    return checkedListItemViews

  ###############
  ### Setters ###
  ###############

  selectedIndexIs: (index) ->
    listItemViews = _.values(@listItemViews)
    if listItemViews.length > index
      listItemView = listItemViews[index]
      @select(listItemView.model) if listItemView?.model?

  ###############
  ### Actions ###
  ###############
  
  moveItemToTop: (emailThread) ->
    @collection.remove(emailThread)
    @collection.unshift(emailThread)

    listItemView = @listItemViews[emailThread.get("uid")]
    trReportEmail = listItemView.$el
    trReportEmail.remove()
    @$el.prepend(trReportEmail)

    listItemView.addedToDOM()

  select: (emailThread, options) ->
    listItemView = @listItemViews?[emailThread.get("uid")]
    return false if not listItemView
    
    @selectedListItemView?.deselect(options)
    @uncheckAll()
    @selectedListItemView = listItemView
    
    listItemView.select(options)
    
    return true
    
  deselect: () ->
    @selectedListItemView?.deselect()
    @selectedListItemView = null

  check: (emailThread, options) ->
    listItemView = @listItemViews?[emailThread.get("uid")]
    return false if not listItemView

    @selectedListItemView?.deselect(options)

    listItemView.check(options)

    return true
    
  checkAll: ->
    listItemView.check() for listItemView in _.values(@listItemViews)

    @selectedListItemView?.deselect()

  checkAllRead: ->
    for listItemView in _.values(@listItemViews)
      seen = listItemView.model.seen
      if seen then listItemView.check() else listItemView.uncheck()

    @selectedListItemView?.deselect()

  checkAllUnread: ->
    for listItemView in _.values(@listItemViews)
      seen = listItemView.model.seen
      if !seen then listItemView.check() else listItemView.uncheck()

    @selectedListItemView?.deselect()

  uncheckAll: ->
    listItemView.uncheck() for listItemView in _.values(@listItemViews)

  moveSelectionUp: ->
    return false if not @selectedListItemView?
    
    selectedItemIndex = _.indexOf(_.values(@listItemViews), @selectedListItemView)
    return false if selectedItemIndex <= 0

    listItemView = _.values(@listItemViews)[selectedItemIndex - 1]
    @select(listItemView.model)

    @scrollListItemIntoView(listItemView, "top")
    
    return listItemView

  moveSelectionDown: ->
    return false if not @selectedListItemView?

    selectedItemIndex = _.indexOf(_.values(@listItemViews), @selectedListItemView)
    return false if selectedItemIndex >= _.size(@listItemViews) - 1

    listItemView = _.values(@listItemViews)[selectedItemIndex + 1]
    @select(listItemView.model)

    @scrollListItemIntoView(listItemView, "bottom")

    return listItemView
    
  scrollListItemIntoView: (listItemView, position) ->
    el = listItemView.$el
    top = el.position().top
    bottom = top + el.outerHeight(true)
    
    parent = @$el.parent().parent()

    if top < 0 || bottom > parent.height()
      if position is "bottom"
        delta = bottom - parent.outerHeight(true)
        parent.scrollTop(parent.scrollTop() + delta)
      else if position is "top"
        delta = -top
        parent.scrollTop(parent.scrollTop() - delta)
      
  ###########################
  ### ListItemView Events ###
  ###########################

  hookListItemViewEvents: (listItemView) ->
    @listenTo(listItemView, "click", (listItemView) =>
      @select(listItemView.model)
    )

    # TODO write tests
    @listenTo(listItemView, "selected", (listItemView) =>
      @trigger("listItemSelected", this, listItemView)
    )

    # TODO write tests
    @listenTo(listItemView, "deselected", (listItemView) =>
      @trigger("listItemDeselected", this, listItemView)
    )

    # TODO write tests
    @listenTo(listItemView, "checked", (listItemView) =>
      @trigger("listItemChecked", this, listItemView)
    )

    # TODO write tests
    @listenTo(listItemView, "unchecked", (listItemView) =>
      @trigger("listItemUnchecked", this, listItemView)
    )
