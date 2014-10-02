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

    @select(@selectedItem(), silent: true) if @selectedItem()?

    return this

  resetView: (models, options) ->
    @removeAll(options.previousModels) if options?.previousModels?
    @selectedListItemView = null

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
    @listItemViews?[emailThread.get("uid")]?.markRead()
    
  markEmailThreadUnread: (emailThread) ->
    @listItemViews?[emailThread.get("uid")]?.markUnread()

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