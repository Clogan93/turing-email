class TuringEmailApp.Collections.EmailFoldersCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailFolder
  url: '/api/v1/email_folders'

  initialize: ->
    @listenTo(this, "remove", @hideModel)
    @listenTo(this, "reset", @hideModels)

  hideModel: (model) ->
    model.trigger("hide")

  hideModels: (models, options) ->
    options.previousModels.forEach(@hideModel, this)

  getEmailFolder: (emailFolderID) ->
    emailFolders = @filter((emailFolder) ->
      emailFolder.get("label_id") is emailFolderID
    )

    return if emailFolders.length > 0 then emailFolders[0] else null
