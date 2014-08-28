class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email#:uid": "show_email"

  show_email: (uid) ->
    email = TuringEmailApp.emailThreads.retrieveEmail uid
    emailView = new TuringEmailApp.Views.Emails.EmailView(model: email)
    emailView.render()

    $("#app").find("#email_content").html(emailView.el)
