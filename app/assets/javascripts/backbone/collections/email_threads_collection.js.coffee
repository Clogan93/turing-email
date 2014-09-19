class TuringEmailApp.Collections.EmailThreadsCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailThread
  url: "/api/v1/email_threads/inbox"

  initialize: (options) ->
    @on("remove", @hideModel)

    page = getQuerystringNameValue("page")
    @url = "/api/v1/email_threads/in_folder?folder_id=" + options.folder_id

    if page != null
      @url += "&page=" + page

  hideModel: (model) ->
    model.trigger("hide")

  getEmailThread: (emailThreadUID) ->
    emailThreads = @filter((emailThread) ->
      emailThread.get("uid") is emailThreadUID
    )

    return if emailThreads.length > 0 then emailThreads[0] else null

  seenIs: (emailThreadUIDs, seenValue=true) ->
    for emailThreadUID in emailThreadUIDs
      emailThread = @getEmailThread emailThreadUID
      emailThread.seenIs(seenValue)

  parse: (response, options) ->
    console.log response
    return response

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
          TuringEmailApp.composeView.clearComposeModal()

        ).fail (data, status) ->
          $("#composeModal").modal "show"
          $("#compose_form").children().hide()
          $("#compose_form").append('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">There was an error in sending your email!</div>')
          setTimeout (->
            $("#compose_form #email_sent_error_alert").remove()
            $("#compose_form").children().show()
          ), 1000

          TuringEmailApp.tattletale.log(JSON.stringify(status))
          TuringEmailApp.tattletale.log(JSON.stringify(data))
          TuringEmailApp.tattletale.send()

      $("#undo_email_send").parent().remove()
    ), 5000

    $("#undo_email_send").click ->
      clearTimeout(TuringEmailApp.sendEmailTimeout)
      $("#composeModal").modal "show"
      $(@).parent().remove()

    $("#composeModal").modal "hide"

    false # to avoid executing the actual submit of the form.
