class TuringEmailApp.Collections.EmailTrackersCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailTracker
  url: "/api/v1/email_trackers"

  initialize: (models, options) ->
    @listenTo(this, "remove", @modelRemoved)
    @listenTo(this, "reset", @modelsReset)

  ##############
  ### Events ###
  ##############

  modelRemoved: (model) ->
    model.trigger("removedFromCollection", this)

  modelsReset: (models, options) ->
    options.previousModels.forEach(@modelRemoved, this)
