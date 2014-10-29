TuringEmailApp.Views.AppsLibrary ||= {}

class TuringEmailApp.Views.AppsLibrary.CreateAppView extends Backbone.View
  template: JST["backbone/templates/apps_library/create_app"]
  
  initialize: (options) ->
    @app = options.app

  render: ->
    @$el.html(@template())
    @setupView()
    return this

  setupView: ->
    @$el.find(".create-app-form").submit => @onSubmit()

  show: ->
    @$el.find(".dropdown a").trigger("click.bs.dropdown")

  hide: ->
    @$el.find(".dropdown a").trigger("click.bs.dropdown")

  resetView: ->
    @$el.find(".create-app-form .create-app-name").val("")
    @$el.find(".create-app-form .create-app-description").val("")
    @$el.find(".create-app-form .create-app-type").val("")
    @$el.find(".create-app-form .create-app-callback-url").val("")
  
  onSubmit: ->
    $.post "/api/v1/apps", {
      name: @$el.find(".create-app-form .create-app-name").val(),
      description: @$el.find(".create-app-form .create-app-description").val(),
      app_type: @$el.find(".create-app-form .create-app-type").val(),
      callback_url: @$el.find(".create-app-form .create-app-callback-url").val()
    }

    alertToken = TuringEmailApp.showAlert("You have successfully created the app!", "alert-success")
    
    setTimeout (=>
      TuringEmailApp.removeAlert(alertToken)
    ), 3000
    
    @resetView()

    @hide()
  
    return false # avoid to execute the actual submit of the form.
