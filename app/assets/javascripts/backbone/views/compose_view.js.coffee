class TuringEmailApp.Views.ComposeView extends Backbone.View
  template: JST["backbone/templates/compose"]

  initialize: ->
    $("#compose_button").click =>
      @resetView()
      @show()
  
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
        @sendEmail()

      return false

    @$el.find("#compose_form #save_button").click =>
      @updateDraft()
      @currentDraft.save()

  show: ->
    $("#composeModal").modal "show"
    
  hide: ->
    $("#composeModal").modal "hide"

  resetView: ->
    $("#compose_form #email_sent_error_alert").remove()

    @currentDraft = null

    @$el.find("#compose_form #email_draft_id_input").val("")
    @$el.find("#compose_form #email_in_reply_to_uid_input").val("")

    @$el.find("#compose_form #to_input").val("")
    @$el.find("#compose_form #cc_input").val("")
    @$el.find("#compose_form #bcc_input").val("")

    @$el.find("#compose_form #subject_input").val("")
    @$el.find("#compose_form #compose_email_body").val("")

  sendEmail: ->
    $("#inbox_title_header").append('<div id="email_sent_success_alert" class="alert alert-info col-md-4" role="alert">
                                       Your message has been sent. <span id="undo_email_send">Undo</span>
                                     </div>')
    
    emailToSend = new TuringEmailApp.Models.Email(url: "/api/v1/email_accounts/send_email")
    @updateEmail(emailToSend)
    @resetView()
    @hide()
    
    TuringEmailApp.sendEmailTimeout = setTimeout (=>
      emailToSend.save(null, {
        error: (model, response, options)=>
          @loadEmail(model.toJSON())
          @show()
          
          $("#compose_form").prepend('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">
                                     There was an error in sending your email!</div>')

          TuringEmailApp.tattletale.log(reponse)
          TuringEmailApp.tattletale.send()
      })

      $("#undo_email_send").parent().remove()
    ), 5000

    $("#undo_email_send").click =>
      clearTimeout(TuringEmailApp.sendEmailTimeout)
      @loadEmail(emailToSend.toJSON())
      @show()

      $("#undo_email_send").parent().remove()
  
  updateDraft: ->
    if not @currentDraft?
      @currentDraft = new TuringEmailApp.Models.Draft()
      emailDraftID = $("#compose_form #email_draft_id_input").val()
      if emailDraftID
        @currentDraft.set("id", emailDraftID)
        @currentDraft.set("draft_id", emailDraftID)

    @updateEmail(@currentDraft)
    
  updateEmail:(email) ->
    email.set("email_in_reply_to_uid", $("#compose_form #email_in_reply_to_uid_input").val())

    email.set("tos", $("#compose_form").find("#to_input").val().split(","))
    email.set("ccs", $("#compose_form").find("#cc_input").val().split(","))
    email.set("bccs",  $("#compose_form").find("#bcc_input").val().split(","))

    email.set("subject", $("#compose_form").find("#subject_input").val())
    email.set("email_body", $("#compose_form").find("#compose_email_body").val())

  subjectWithPrefixFromEmail: (email, subjectPrefix="") ->
    return subjectPrefix if not email.subject
    
    subjectWithoutForwardPrefix = email.subject.replace("Fwd: ", "")
    subjectWithoutForwardAndReplyPrefixes = subjectWithoutForwardPrefix.replace("Re: ", "")
    return subjectPrefix + subjectWithoutForwardAndReplyPrefixes    
    
  loadEmail: (email, insertReplyHeader=false) ->
    @resetView()
    
    $("#compose_form #to_input").val(email.tos)
    $("#compose_form #cc_input").val(email.ccs)
    $("#compose_form #bcc_input").val(email.bccs)

    $("#compose_form #subject_input").val(@subjectWithPrefixFromEmail(email.subject))

    @loadBodyFromEmail(email, insertReplyHeader)
    
  loadEmailDraft: (emailDraft, emailInReplyToUID="") ->
    @loadEmail(emailDraft)
    
    emailDraftID = TuringEmailApp.emailDraftIDs.getEmailDraftID(emailDraft.uid)
    $("#compose_form #email_draft_id_input").val(emailDraftID)
    $("#compose_form #email_in_reply_to_uid_input").val(emailInReplyToUID)

  loadEmailAsReply: (email, subjectPrefix="Re: ") ->
    @resetView()
    
    $("#compose_form #email_in_reply_to_uid_input").val(email.uid)

    $("#compose_form #to_input").val(if email.reply_to_address? then email.reply_to_address else email.from_address)
    $("#compose_form #subject_input").val(@subjectWithPrefixFromEmail(email.subject, subjectPrefix))

    @loadBodyFromEmail(email, true)

  loadEmailAsForward: (email) ->
    @resetView()

    $("#compose_form #subject_input").val(@subjectWithPrefixFromEmail(email.subject, "Fwd: "))
    
    @loadBodyFromEmail(email, true)
    
  loadBodyFromEmail: (email, insertReplyHeader=false) ->
    body = ""
    body += "\r\n\r\n\r\n\r\n" if insertReplyHeader

    if email.text_part?
      body += email.text_part if email.text_part
    else
      body += email.body_text if email.body_text

    $("#compose_form #compose_email_body").val(body)
