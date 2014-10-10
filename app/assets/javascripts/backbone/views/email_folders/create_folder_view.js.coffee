TuringEmailApp.Views.EmailFolders ||= {}

class TuringEmailApp.Views.EmailFolders.CreateFolderView extends Backbone.View
  template: JST["backbone/templates/email_folders/create_folder"]

  initialize: (options) ->
    @app = options.app
  
  render: ->
    @$el.html(@template())
    @setupCreateFolderView()
    return this

  setupCreateFolderView: ->
    @$el.find(".createFolderForm").submit =>
      console.log "Creating folder..."

      @trigger "createFolderFormSubmitted", this, @folderType, $(".createFolderForm .createFolderInput").val()

      @hide()

      return false

  show: ->
    @$el.find(".createFolderModal").modal "show"
    
  hide: ->
    @$el.find(".createFolderModal").modal "hide"
