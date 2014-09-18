# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#######################################################
#################### Email Sending ####################
#######################################################

$ ->
  $("#compose_form").submit ->
    if TuringEmailApp.currentEmailThread? and TuringEmailApp.currentEmailThread.get("uid")? and TuringEmailApp.emailThreads? and TuringEmailApp.emailThreads.drafts? and TuringEmailApp.emailThreads.drafts.models? and TuringEmailApp.emailThreads.drafts.models[0].attributes?
      TuringEmailApp.emailThreads.drafts.updateDraft(true)
    else
      TuringEmailApp.emailThreads.drafts.sendEmail()

  $("#compose_form #save_button").click ->
    TuringEmailApp.emailThreads.drafts.updateDraft()

#########################################################
#################### Email Filtering ####################
#########################################################

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
