class TuringEmailApp.Collections.EmailFoldersCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailFolder
  url: '/api/v1/email_folders'

  initialize: ->
    @listenTo(this, "remove", @modelRemoved)
    @listenTo(this, "reset", @modelsReset)

  modelRemoved: (model) ->
    model.trigger("removedFromCollection", this)

  modelsReset: (models, options) ->
    options.previousModels.forEach(@modelRemoved, this)

  getEmailFolder: (emailFolderID) ->
    emailFolders = @filter((emailFolder) ->
      emailFolder.get("label_id") is emailFolderID
    )

    return if emailFolders.length > 0 then emailFolders[0] else null
