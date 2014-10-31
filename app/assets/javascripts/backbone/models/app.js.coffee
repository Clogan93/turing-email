class TuringEmailApp.Models.App extends Backbone.Model
  idAttribute: "uid"

  @Install: (appID) ->
    $.post "/api/v1/apps/install/" + appID
