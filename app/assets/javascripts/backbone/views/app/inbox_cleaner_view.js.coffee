TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.InboxCleanerView extends Backbone.View
  template: JST["backbone/templates/app/inbox_cleaner"]

  className: "inbox-cleaner"

  render: ->
    @$el.html(@template())
    return this
