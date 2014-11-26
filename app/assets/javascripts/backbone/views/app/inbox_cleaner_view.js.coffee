TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.InboxCleanerView extends Backbone.View
  template: JST["backbone/templates/app/inbox_cleaner"]

  className: "inbox-cleaner"

  initialize: (options) ->
    @app = options.app
    
    if @model
      @listenTo(@model, "change", @render)
      @listenTo(@model, "destroy", @remove)
  
  render: ->
    @$el.empty()

    @$el.html(@template(@model.toJSON())) if _.keys(@model.attributes).length > 0
    
    @setupButtons()
    
    return this

  setupButtons: ->
    @$el.find(".auto-file-button").click (event) =>
      $(event.currentTarget).prop("disabled", true);
      @app.showAlert("The emails are being filed away!", "alert-info", 5000)
      
      TuringEmailApp.Models.CleanerReport.Apply().done(
        => @model.fetch()
      )
