class TuringEmailApp.Views.ComposeView extends Backbone.View
  template: JST["backbone/templates/compose"]

  initialize: ->
    return

  remove: ->
    @$el.remove()

  render: ->
    
    @$el.html(@template())

    @setupComposeView()

    return this

  setupComposeView: ->
    $("#compose_form").submit ->
      if TuringEmailApp.currentEmailThread? and TuringEmailApp.currentEmailThread.get("uid")? and TuringEmailApp.emailThreads? and TuringEmailApp.emailThreads.drafts? and TuringEmailApp.emailThreads.drafts.models? and TuringEmailApp.emailThreads.drafts.models[0].attributes?
        TuringEmailApp.emailThreads.drafts.updateDraft(true)
      else
        TuringEmailApp.emailThreads.sendEmail()

    $("#compose_form #save_button").click ->
      TuringEmailApp.emailThreads.drafts.updateDraft()

  clearComposeModal: ->
    $("#compose_form #to_input").val("")
    $("#compose_form #cc_input").val("")
    $("#compose_form #bcc_input").val("")
    $("#compose_form #subject_input").val("")
    $("#compose_form #compose_email_body").val("")
    $("#compose_form #email_in_reply_to_uid_input").val("")
