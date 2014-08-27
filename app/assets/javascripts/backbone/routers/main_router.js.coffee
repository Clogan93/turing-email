class TuringEmailApp.Routers.MainRouter extends Backbone.Router
  routes:
    "label#:id": "show_label_info"
    "email#:uid": "show_email"

  show_label_info: (id) ->
    this.Collections.emailFolder = new EmailFolder()
    this.Collections.emailFolder.url = "/api/v1/email_threads/in_folder?folder_id=" + id.toString()
    this.Views.emailFolderView = new EmailFolderView(collection: this.Collections.emailFolder)
    $("#app").html this.Views.emailFolderView.el
    this.Collections.emailFolder.fetch  success: (collection, response, options) ->
      TuringEmailApp.Views.emailFolderView.render()

      TuringEmailApp.bind_collapsed_email_thread_functionality()

      return
    return

  show_email: (uid) ->
    email = this.Collections.inbox.retrieveEmail uid
    email = this.Collections.emailFolder.retrieveEmail uid  if email is `undefined`
    this.Views.emailView = new EmailView({ model: email });
    this.Views.emailView.render()
    $("#app").find("#email_content").html this.Views.emailView.el

    this.bind_collapsed_email_thread_functionality()

  bind_collapsed_email_thread_functionality: ->
    $(".email").click ->
      $(this).find(".email_body").show()
      $(this).removeClass("collapsed_email")
      console.log $(this).siblings(".email").each ->
        $(this).addClass "collapsed_email"
        $(this).find(".email_body").hide()

    return
