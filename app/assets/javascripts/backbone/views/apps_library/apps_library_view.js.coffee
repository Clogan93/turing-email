TuringEmailApp.Views.AppsLibrary ||= {}

class TuringEmailApp.Views.AppsLibrary.AppsLibraryView extends Backbone.View
  template: JST["backbone/templates/apps_library/apps_library"]
  
  initialize: (options) ->
    @listenTo(@collection, "add", => @render())
    @listenTo(@collection, "remove", => @render())
    @listenTo(@collection, "reset", => @render())
    @listenTo(@collection, "destroy", => @render())
    
    @developer_enabled = options.developer_enabled

  render: ->
    @$el.html(@template(developer_enabled: @developer_enabled, apps: @collection.toJSON()))

    @setupButtons()
    
    return this

  setupButtons: ->
    @createAppView = new TuringEmailApp.Views.AppsLibrary.CreateAppView(
      app: TuringEmailApp
      el: @$el.find(".create_app_view")
    )
    @createAppView.render()
    
    @$el.find(".create-app-button").click (event) =>
      @onCreateAppButtonClick(event)

    @$el.find(".install-app-button").click (event) =>
      @onInstallAppButtonClick(event)

  onCreateAppButtonClick: (event) ->
    @createAppView.show()

    return false

  onInstallAppButtonClick: (event) ->
    index = @$el.find(".install-app-button").index(event.currentTarget)
    app = @collection.at(index)

    @trigger("installAppClicked", this, app.get("uid"))
    
    alertToken = TuringEmailApp.showAlert("You have installed the app!", "alert-success")

    setTimeout (=>
      TuringEmailApp.removeAlert(alertToken)
    ), 3000

    return false
