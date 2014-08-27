class TuringEmailApp.Routers.EmailsRouter extends Backbone.Router
  initialize: (options) ->
    @emails = new TuringEmailApp.Collections.EmailsCollection()
    @emails.reset options.emails

  routes:
    "index"    : "index"
    ".*"        : "index"
    ":id"      : "show"

  index: ->
    alert("emails index")

  show: (id) ->
    email = @emails.get(id)

    @view = new TuringEmailApp.Views.Emails.ShowView(model: email)
    $("#emails").html(@view.render().el)
