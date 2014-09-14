# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#compose_form").submit ->
    #Data preparation
    postData = {}
    postData.tos = $(@).find("#to_input").val().split(",")
    postData.subject = $(@).find("#subject_input").val()
    postData.email_body = $(@).find("#compose_email_body").val()

    $.ajax({
      url: 'api/v1/email_accounts/send_email.json'
      type: 'POST'
      data: postData
      dataType : "text"
      }).done((data, status) ->
        console.log "Success function called"
        console.log data
        console.log status
        $("#compose_form").children().hide()
        $("#compose_form").append('<div id="email_sent_success_alert" class="alert alert-success" role="alert">You have successfully sent your email!</div>')
        setTimeout (->
          $("#composeModal").modal "hide"
          $("#compose_form").children().show()
          $("#compose_form #email_sent_success_alert").hide()
        ), 1000
      ).fail (data, status) ->
        console.log "Error function called"
        console.log data
        console.log status
        $("#compose_form").children().hide()
        $("#compose_form").append('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">There was an error in sending your email!</div>')
        setTimeout (->
          $("#compose_form").children().show()
          $("#compose_form #email_sent_error_alert").hide()
        ), 1000

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
