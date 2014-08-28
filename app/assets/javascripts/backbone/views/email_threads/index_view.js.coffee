TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.IndexView extends Backbone.View
  template: JST["backbone/templates/email_threads/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (emailThread) =>
    view = new TuringEmailApp.Views.EmailThreads.EmailThreadView({model : emailThread})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(emailThreads: @collection.toJSON() ))
    @addAll()

    return this
