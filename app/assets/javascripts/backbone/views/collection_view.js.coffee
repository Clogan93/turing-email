class TuringEmailApp.Views.CollectionView extends Backbone.View
  initialize: (options) ->
    @listenTo(@collection, "add", => @render())
    @listenTo(@collection, "remove", => @render())
    @listenTo(@collection, "reset", => @render())
    @listenTo(@collection, "destroy", => @render())
