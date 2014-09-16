# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#######################################################
#################### Email Sending ####################
#######################################################

$ ->
  $("#compose_form").submit ->
    if TuringEmailApp.currentEmailThread? and TuringEmailApp.currentEmailThread.get("uid")? and TuringEmailApp.emailThreads? and TuringEmailApp.emailThreads.draftIds? and TuringEmailApp.emailThreads.draftIds.models? and TuringEmailApp.emailThreads.draftIds.models[0].attributes?
      TuringEmailApp.emailThreadsRouter.updateDraft(true)
    else
      TuringEmailApp.emailThreadsRouter.sendEmail()

  $("#compose_form #save_button").click ->
    TuringEmailApp.emailThreadsRouter.updateDraft()

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
