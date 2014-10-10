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
    @$el.find(".create-folder-form").submit =>
      console.log "Creating folder..."

      @trigger "createFolderFormSubmitted", this, @mode, $(".create-folder-form .create-folder-input").val()

      @hide()

      return false

  show: (mode) ->
    @mode = mode
    @$el.find(".create-folder-modal").modal "show"
    
  hide: ->
    @$el.find(".create-folder-modal").modal "hide"
