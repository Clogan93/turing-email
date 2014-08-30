TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListView extends Backbone.View
  initialize: ->
    @listenTo(@collection, "add", @addOne)
    @listenTo(@collection, "reset", @addAll)

  render: ->
    @addAll()

  addOne: (thread) ->
    listItemView = new TuringEmailApp.Views.EmailThreads.ListItemView(model: thread)
    @$el.append(listItemView.render().el)

  addAll: ->
    @$el.empty()
    @collection.forEach @addOne, this

  destroy: () ->
    @model.destroy()
    this.remove()

    return false
