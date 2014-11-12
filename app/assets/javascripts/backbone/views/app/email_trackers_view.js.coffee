TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.EmailTrackersView extends Backbone.View
  template: JST["backbone/templates/app/email_trackers"]
  
  initialize: (options) ->
    @listenTo(@collection, "add", => @render())
    @listenTo(@collection, "remove", => @render())
    @listenTo(@collection, "reset", => @render())
    @listenTo(@collection, "destroy", => @render())

  render: ->
    @$el.html(@template(emailTrackers: @collection.toJSON()))
    
    return this
