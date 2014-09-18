class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email_thread#:uid": "showEmailThread"
    "email_draft#:uid": "showEmailDraft"

  showEmailThread: (emailThreadUID) ->
    if TuringEmailApp.userSettings.get("split_pane_mode") is "horizontal"
      $("#preview_panel").show()
      TuringEmailApp.currentEmailThread = TuringEmailApp.emailThreads.getEmailThread(emailThreadUID)

      TuringEmailApp.previewEmailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
        model: TuringEmailApp.currentEmailThread
        el: $("#preview_content")
      )
      TuringEmailApp.previewEmailThreadView.render()
    else
      TuringEmailApp.currentEmailThread = TuringEmailApp.emailThreads.getEmailThread(emailThreadUID)
      
      if TuringEmailApp.currentEmailThread?
        @renderEmailThread TuringEmailApp.currentEmailThread
      else
        TuringEmailApp.currentEmailThread = new TuringEmailApp.Models.EmailThread()
        TuringEmailApp.currentEmailThread.url = "/api/v1/email_threads/show/" + emailThreadUID
        
        TuringEmailApp.currentEmailThread.fetch(
          success: (model, response, options) =>
            @renderEmailThread model
        )

  renderEmailThread: (emailThread) ->
    $("#email-folder-mail-header").hide()
    emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: emailThread
      el: $("#email_table_body")
    )
    
    emailThreadView.render()

  showEmailDraft: (emailThreadUID) ->
    TuringEmailApp.currentEmailThread = TuringEmailApp.emailThreads.getEmailThread(emailThreadUID)

    TuringEmailApp.emailThreads.drafts = new TuringEmailApp.Collections.DraftsCollection()
    TuringEmailApp.emailThreads.drafts.fetch()

    if TuringEmailApp.currentEmailThread?
      TuringEmailApp.emailThreadsListView.prepareComposeModalWithEmailThreadData TuringEmailApp.currentEmailThread.get("emails")[0], ""
    else
      TuringEmailApp.currentEmailThread = new TuringEmailApp.Models.EmailThread()
      TuringEmailApp.currentEmailThread.url = "/api/v1/email_threads/show/" + emailThreadUID
      
      TuringEmailApp.currentEmailThread.fetch(
        success: (model, response, options) =>
          console.log model
          TuringEmailApp.emailThreadsListView.prepareComposeModalWithEmailThreadData model.get("emails")[0], ""
      )

  ##################################################################
  ######################### Sending Emails #########################
  ##################################################################

  sendEmail: ->
    $("#inbox_title_header").append('<div id="email_sent_success_alert" class="alert alert-info col-md-4" role="alert">Your message has been sent. <span id="undo_email_send">Undo</span></div>')

    TuringEmailApp.sendEmailTimeout = setTimeout (->
      #Data preparation
      postData = {}
      postData.tos = $("#compose_form #to_input").val().split(",")
      postData.ccs = $("#compose_form #cc_input").val().split(",")
      postData.bccs = $("#compose_form #bcc_input").val().split(",")
      postData.subject = $("#compose_form #subject_input").val()
      postData.email_body = $("#compose_form #compose_email_body").val()
      postData.email_in_reply_to_uid_input = $("#compose_form #email_in_reply_to_uid_input").val()

      $.ajax({
        url: 'api/v1/email_accounts/send_email.json'
        type: 'POST'
        data: postData
        dataType : 'json'
        }).done((data, status) ->
          #Clear input form fields.
          $("#compose_form").find("#to_input").val("")
          $("#compose_form").find("#subject_input").val("")
          $("#compose_form").find("#compose_email_body").val("")
          TuringEmailApp.emailThreadsRouter.clearComposeModal()

        ).fail (data, status) ->
          $("#composeModal").modal "show"
          $("#compose_form").children().hide()
          $("#compose_form").append('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">There was an error in sending your email!</div>')
          setTimeout (->
            $("#compose_form #email_sent_error_alert").remove()
            $("#compose_form").children().show()
          ), 1000

      $("#undo_email_send").parent().remove()
    ), 5000

    $("#undo_email_send").click ->
      clearTimeout(TuringEmailApp.sendEmailTimeout)
      $("#composeModal").modal "show"
      $(@).parent().remove()

    $("#composeModal").modal "hide"

    false # to avoid executing the actual submit of the form.

  clearComposeModal: ->
    $("#compose_form #to_input").val("")
    $("#compose_form #cc_input").val("")
    $("#compose_form #bcc_input").val("")
    $("#compose_form #subject_input").val("")
    $("#compose_form #compose_email_body").val("")
    $("#compose_form #email_in_reply_to_uid_input").val("")
