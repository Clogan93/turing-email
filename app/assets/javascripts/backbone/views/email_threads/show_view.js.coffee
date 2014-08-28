TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ShowView extends Backbone.View
  template: JST["backbone/templates/email_threads/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
