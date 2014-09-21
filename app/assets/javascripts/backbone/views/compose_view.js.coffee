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
    @$el.find("#compose_form").submit ->
      if TuringEmailApp.currentEmailThread? and TuringEmailApp.currentEmailThread.get("uid")? and TuringEmailApp.emailThreads? and TuringEmailApp.emailThreads.drafts? and TuringEmailApp.emailThreads.drafts.models? and TuringEmailApp.emailThreads.drafts.models[0].attributes?
        TuringEmailApp.emailThreads.drafts.updateDraft(true)
      else
        TuringEmailApp.emailThreads.sendEmail()

    @$el.find("#compose_form #save_button").click ->
      TuringEmailApp.emailThreads.drafts.updateDraft()

  clearComposeModal: ->
    @$el.find("#compose_form #to_input").val("")
    @$el.find("#compose_form #cc_input").val("")
    @$el.find("#compose_form #bcc_input").val("")
    @$el.find("#compose_form #subject_input").val("")
    @$el.find("#compose_form #compose_email_body").val("")
    @$el.find("#compose_form #email_in_reply_to_uid_input").val("")

  prepareComposeModalWithEmailData: (email, subject_prefix="Re: ") ->
    if email.reply_to_address?
      $("#compose_form #to_input").val(email.reply_to_address)
    else
      $("#compose_form #to_input").val(email.from_address)

    @prepareEmailSubjectWithEmailData email, subject_prefix   

    @prepareEmailBodyWithEmailData email

    $("#composeModal").modal "show"

  prepareEmailSubjectWithEmailData: (email, subject_prefix) ->
    subjectWithoutForwardPrefix = email.subject.replace("Fwd: ", "")
    subjectWithoutForwardAndReplyPrefixes = subjectWithoutForwardPrefix.replace("Re: ", "")
    $("#compose_form #subject_input").val(subject_prefix + subjectWithoutForwardAndReplyPrefixes)

  prepareEmailBodyWithEmailData: (email) ->
    $("#compose_form #compose_email_body").val("\r\n\r\n\r\n\r\n" + @retrieveEmailBodyAttributeToUseBasedOnAvailableAttributes(email))

  retrieveEmailBodyAttributeToUseBasedOnAvailableAttributes: (email) ->
    if email.html_part?
      return email.html_part
    else if email.text_part?
      return email.text_part
    else if email.body_text?
      return email.body_text
    else
      return ""
