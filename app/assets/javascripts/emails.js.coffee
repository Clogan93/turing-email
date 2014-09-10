# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#compose_form").submit ->
    url = "/send_emails"
    $.ajax
      type: "POST"
      url: url
      data: $("#compose_form").serialize() # serializes the form's elements.
      success: (data) ->
        alert data # show response from the php script.
        return

    false # avoid to execute the actual submit of the form.

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
        alert data # show response from the php script.
        return

    $('.dropdown a').trigger('click.bs.dropdown')

    false # avoid to execute the actual submit of the form.
