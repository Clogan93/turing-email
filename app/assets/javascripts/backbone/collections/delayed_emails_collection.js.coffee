class TuringEmailApp.Collections.DelayedEmailsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.DelayedEmail
  url: "/api/v1/delayed_emails"

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
