class TuringEmailApp.Routers.EmailThreadsRouter extends Backbone.Router
  routes:
    "email_thread#:uid": "showEmailThread"
    "email_draft#:uid": "showEmailDraft"

  showEmailThread: (emailThreadUID) ->
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
    emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: emailThread
      el: $("#email_table_body")
    )
    
    emailThreadView.render()

  showEmailDraft: (emailThreadUID) ->
    TuringEmailApp.currentEmailThread = TuringEmailApp.emailThreads.getEmailThread(emailThreadUID)

    TuringEmailApp.emailThreads.draftIds = new TuringEmailApp.Collections.DraftsCollection()
    TuringEmailApp.emailThreads.draftIds.fetch()

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

  sendEmail: ->
    $("#inbox_title_header").append('<div id="email_sent_success_alert" class="alert alert-info col-md-4" role="alert">Your message has been sent. <span id="undo_email_send">Undo</span></div>')

    TuringEmailApp.sendEmailTimeout = setTimeout (->
      #Data preparation
      postData = {}
      postData.tos = $("#compose_form").find("#to_input").val().split(",")
      postData.ccs = $("#compose_form").find("#cc_input").val().split(",")
      postData.bccs = $("#compose_form").find("#bcc_input").val().split(",")
      postData.subject = $("#compose_form").find("#subject_input").val()
      postData.email_body = $("#compose_form").find("#compose_email_body").val()

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

  updateDraft: (shouldSend=false) ->
    postData = {}
    postData.tos = $("#compose_form").find("#to_input").val().split(",")
    postData.ccs = $("#compose_form").find("#cc_input").val().split(",")
    postData.bccs = $("#compose_form").find("#bcc_input").val().split(",")
    postData.subject = $("#compose_form").find("#subject_input").val()
    postData.email_body = $("#compose_form").find("#compose_email_body").val()
    if TuringEmailApp.currentEmailThread? and TuringEmailApp.currentEmailThread.get("uid")? and TuringEmailApp.emailThreads? and TuringEmailApp.emailThreads.draftIds? and TuringEmailApp.emailThreads.draftIds.models? and TuringEmailApp.emailThreads.draftIds.models[0].attributes?
      draftIds = TuringEmailApp.emailThreads.draftIds.models[0].attributes
      postData.draft_id = draftIds[TuringEmailApp.currentEmailThread.get("uid")]
      postUrl = 'api/v1/email_accounts/update_draft.json'
    else 
      postUrl = 'api/v1/email_accounts/create_draft.json'
    $.ajax({
      url: postUrl
      type: 'POST'
      data: postData
      dataType : 'json'
      }).done((data, status) =>
        if shouldSend
          @sendDraft postData.draft_id
        console.log status
        console.log data
      ).fail (data, status) ->
        console.log status
        console.log data

  sendDraft: (draft_id) ->
    postData = {}
    postData.draft_id = draft_id
    $.ajax({
      url: 'api/v1/email_accounts/send_draft.json'
      type: 'POST'
      data: postData
      dataType : 'json'
      }).done((data, status) ->
        console.log status
        console.log data
      ).fail (data, status) ->
        console.log status
        console.log data

    @clearComposeModal()
    $("#composeModal").modal "hide"

  clearComposeModal: ->
    $("#compose_form").find("#to_input").val("")
    $("#compose_form").find("#cc_input").val("")
    $("#compose_form").find("#bcc_input").val("")
    $("#compose_form").find("#subject_input").val("")
    $("#compose_form").find("#compose_email_body").val("")
