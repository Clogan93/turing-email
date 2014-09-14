# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#compose_form").submit ->
    $("#inbox_title_header").append('<div id="email_sent_success_alert" class="alert alert-info col-md-4" role="alert">Your message has been sent. <span id="undo_email_send">Undo</span></div>')

    TuringEmailApp.sendEmailTimeout = setTimeout (->
      #Data preparation
      postData = {}
      postData.tos = $("#compose_form").find("#to_input").val().split(",")
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

$ ->
  $(".create_filter").click ->
    $('.dropdown a').trigger('click.bs.dropdown')
    return false

  $("#filter_form").submit ->
    url = "/api/v1/genie_rules.json"
    $.ajax
      type: "POST"
      url: url
      data: $("#filter_form").serialize() # serializes the form's elements.
      success: (data) ->
        alert data
        return

    $('.dropdown a').trigger('click.bs.dropdown')

    false # avoid to execute the actual submit of the form.
