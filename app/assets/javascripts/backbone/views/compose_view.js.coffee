class TuringEmailApp.Views.ComposeView extends Backbone.View
  template: JST["backbone/templates/compose"]

  initialize: ->
    $("#compose_button").click =>
      @resetView()
      $("#composeModal").modal "show"
  
  remove: ->
    @$el.remove()

  render: ->
    @$el.html(@template())
    @setupComposeView()
    return this

  setupComposeView: ->
    @$el.find("#compose_form").submit =>
      if @currentDraft?
        @updateDraft()
        @currentDraft.save()
        @currentDraft.send()
      else
        TuringEmailApp.emailThreads.sendEmail()

    @$el.find("#compose_form #save_button").click =>
      @updateDraft()
      @currentDraft.save()

  updateDraft: ->
    if not @currentDraft?
      @currentDraft = new TuringEmailApp.Models.Draft()
      emailDraftID = $("#compose_form #email_draft_id_input").val()
      if emailDraftID
        @currentDraft.set("id", emailDraftID)
        @currentDraft.set("draft_id", emailDraftID)

    @currentDraft.set("email_in_reply_to_uid", $("#compose_form #email_in_reply_to_uid_input").val())
      
    @currentDraft.set("tos", $("#compose_form").find("#to_input").val().split(","))
    @currentDraft.set("ccs", $("#compose_form").find("#cc_input").val().split(","))
    @currentDraft.set("bccs",  $("#compose_form").find("#bcc_input").val().split(","))

    @currentDraft.set("subject", $("#compose_form").find("#subject_input").val())
    @currentDraft.set("email_body", $("#compose_form").find("#compose_email_body").val())

  resetView: ->
    @currentDraft = null
    
    @$el.find("#compose_form #email_draft_id_input").val("")
    @$el.find("#compose_form #email_in_reply_to_uid_input").val("")
    
    @$el.find("#compose_form #to_input").val("")
    @$el.find("#compose_form #cc_input").val("")
    @$el.find("#compose_form #bcc_input").val("")
    
    @$el.find("#compose_form #subject_input").val("")
    @$el.find("#compose_form #compose_email_body").val("")

  loadEmailDraft: (emailDraft, emailInReplyToUID="") ->
    @resetView()
    
    emailDraftID = TuringEmailApp.emailDraftIDs.getEmailDraftID(emailDraft.uid)
    $("#compose_form #email_draft_id_input").val(emailDraftID)
    $("#compose_form #email_in_reply_to_uid_input").val(emailInReplyToUID)
    
    $("#compose_form #to_input").val(emailDraft.tos)
    $("#compose_form #cc_input").val(emailDraft.ccs)
    $("#compose_form #bcc_input").val(emailDraft.bccs)

    $("#compose_form #to_input").val(if emailDraft.reply_to_address? then emailDraft.reply_to_address else emailDraft.from_address)
    $("#compose_form #subject_input").val(emailDraft.subject)
  
    @loadBodyFromEmail emailDraft
  
    $("#composeModal").modal "show"

  loadEmail: (email, subject_prefix="Re: ") ->
    @resetView()
    
    $("#compose_form #email_in_reply_to_uid_input").val(email.uid)

    $("#compose_form #to_input").val(if email.reply_to_address? then email.reply_to_address else email.from_address)
    $("#compose_form #subject_input").val(subject_prefix + email.subject)

    @loadBodyFromEmail(email, true)

    $("#composeModal").modal "show"

  loadBodyFromEmail: (email, insertReplyHeader=false) ->
    body = ""
    body += "\r\n\r\n\r\n\r\n" if insertReplyHeader
    
    if email.text_part?
      body += email.text_part
    else
      body += email.body_text

    $("#compose_form #compose_email_body").val(body)
