TuringEmailApp.Views.AppsLibrary ||= {}

class TuringEmailApp.Views.AppsLibrary.AppsLibraryView extends Backbone.View
  template: JST["backbone/templates/apps_library/apps_library"]
  
  initialize: (options) ->
    @listenTo(@collection, "add", @render)
    @listenTo(@collection, "remove", @render)
    @listenTo(@collection, "reset", @render)
    @listenTo(@collection, "destroy", @render)

  render: ->
    @$el.html(@template(apps: @collection.toJSON()))

    @setupButtons()
    
    return this

  setupButtons: ->
    @createAppView = new TuringEmailApp.Views.AppsLibrary.CreateAppView(
      app: TuringEmailApp
      el: @$el.find(".create_app_view")
    )
    @createAppView.render()
    
    @$el.find(".create_app_button").click (event) =>
      @onCreateAppButtonClick(event)

    @$el.find(".install_app_button").click (event) =>
      @onInstallAppButtonclick(event)

  onCreateAppButtonClick: (event) ->
    @createAppView.show()

    return false
    
  onInstallAppButtonclick: (event) ->
    index = @$el.find(".install_app_button").index(event.currentTarget)
    app = @collection.at(index)

    $.post "/api/v1/apps/install/" + app.get("uid")
    
    alertToken = TuringEmailApp.showAlert("You have installed the app!", "alert-success")

    setTimeout (=>
      TuringEmailApp.removeAlert(alertToken)
    ), 3000

    return false
