class TuringEmailApp.Views.ComposeView extends Backbone.View
  template: JST["backbone/templates/compose"]

  initialize: ->
    $("#compose_button").click =>
      @resetView()
      @show()

  render: ->
    @$el.html(@template())
    @setupComposeView()
    return this

  setupComposeView: ->
    @$el.find("#compose_form").submit =>
      console.log "SEND clicked! Sending..."
      @sendEmail()
      return false

    @$el.find("#compose_form #save_button").click =>
      console.log "SAVE clicked - saving the draft!"
      
      # if already in the middle of saving, no reason to save again
      # it could be an error to save again if the draft_id isn't set because it would create duplicate drafts
      if @savingDraft
        console.log "SKIPPING SAVE - already saving!!"
        return
        
      @savingDraft = true

      @updateDraft()

      @currentEmailDraft.save(null, {
        success: (model, response, options) =>
          console.log "SAVED! setting draft_id to " + response.draft_id
          model.set("draft_id", response.draft_id)
          @trigger "change:draft", this
          
          @savingDraft = false
          
        error: (model, response, options) =>
          console.log "SAVE FAILED!!!"
          @savingDraft = false
      })

  show: ->
    $("#composeModal").modal "show"
    
  hide: ->
    $("#composeModal").modal "hide"

  showEmailSentAlert:(emailSentJSON) ->
    console.log "ComposeView showEmailSentAlert"
    
    $("#inbox_title_header").append('<div id="email_sent_success_alert" class="alert alert-info col-md-4" role="alert">
                                       Your message has been sent. <span id="undo_email_send">Undo</span>
                                     </div>')
    $("#undo_email_send").click =>
      clearTimeout(TuringEmailApp.sendEmailTimeout)
      @loadEmail(emailSentJSON)
      @show()
  
  removeEmailSentAlert: ->
    console.log "ComposeView REMOVE emailSentAlert"
    
    $("#email_sent_success_alert").remove()
    
  resetView: ->
    console.log("ComposeView RESET!!")
    
    $("#compose_form #email_sent_error_alert").remove()
    @removeEmailSentAlert()

    @currentEmailDraft = null
    @emailInReplyToUID = null

    @$el.find("#compose_form #to_input").val("")
    @$el.find("#compose_form #cc_input").val("")
    @$el.find("#compose_form #bcc_input").val("")

    @$el.find("#compose_form #subject_input").val("")
    @$el.find("#compose_form #compose_email_body").val("")

  loadEmail: (emailJSON) ->
    console.log("ComposeView loadEmail!!")
    @resetView()

    @loadEmailHeaders(emailJSON)
    @loadEmailBody(emailJSON)
    
  loadEmailDraft: (emailDraftJSON, emailInReplyToUID=null) ->
    console.log("ComposeView loadEmailDraft!!")
    @resetView()
    
    @loadEmailHeaders(emailDraftJSON)
    @loadEmailBody(emailDraftJSON)

    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft(emailDraftJSON)
    @emailInReplyToUID = emailInReplyToUID

  loadEmailAsReply: (emailJSON) ->
    console.log("ComposeView loadEmailAsReply!!")
    @resetView()

    $("#compose_form #to_input").val(if emailJSON.reply_to_address? then emailJSON.reply_to_address else emailJSON.from_address)
    $("#compose_form #subject_input").val(@subjectWithPrefixFromEmail(emailJSON, "Re: "))
    @loadEmailBody(emailJSON, true)

    @emailInReplyToUID = emailJSON.uid

  loadEmailAsForward: (emailJSON) ->
    console.log("ComposeView loadEmailAsForward!!")
    @resetView()

    $("#compose_form #subject_input").val(@subjectWithPrefixFromEmail(emailJSON, "Fwd: "))
    @loadEmailBody(emailJSON, true)

  loadEmailHeaders: (emailJSON) ->
    console.log("ComposeView loadEmailHeaders!!")
    $("#compose_form #to_input").val(emailJSON.tos)
    $("#compose_form #cc_input").val(emailJSON.ccs)
    $("#compose_form #bcc_input").val(emailJSON.bccs)

    $("#compose_form #subject_input").val(@subjectWithPrefixFromEmail(emailJSON))
    
  loadEmailBody: (emailJSON, insertReplyHeader=false) ->
    console.log("ComposeView loadEmailBody!!")
    body = ""
    body += "\r\n\r\n\r\n\r\n" if insertReplyHeader

    if emailJSON.text_part?
      body += emailJSON.text_part if emailJSON.text_part
    else
      body += emailJSON.body_text if emailJSON.body_text

    $("#compose_form #compose_email_body").val(body)

  subjectWithPrefixFromEmail: (emailJSON, subjectPrefix="") ->
    console.log("ComposeView subjectWithPrefixFromEmail")
    return subjectPrefix if not emailJSON.subject

    subjectWithoutForwardPrefix = emailJSON.subject.replace("Fwd: ", "")
    subjectWithoutForwardAndReplyPrefixes = subjectWithoutForwardPrefix.replace("Re: ", "")
    return subjectPrefix + subjectWithoutForwardAndReplyPrefixes

  updateDraft: ->
    console.log "ComposeView updateDraft!"
    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft() if not @currentEmailDraft?
    @updateEmail(@currentEmailDraft)

  updateEmail:(email) ->
    console.log "ComposeView updateEmail!"
    email.set("email_in_reply_to_uid", @emailInReplyToUID)

    email.set("tos", $("#compose_form").find("#to_input").val().split(","))
    email.set("ccs", $("#compose_form").find("#cc_input").val().split(","))
    email.set("bccs",  $("#compose_form").find("#bcc_input").val().split(","))

    email.set("subject", $("#compose_form").find("#subject_input").val())
    email.set("email_body", $("#compose_form").find("#compose_email_body").val())

  sendEmail:(draftToSend=null) ->
    console.log "ComposeView sendEmail!"
    
    if @currentEmailDraft? || draftToSend?
      console.log "sending DRAFT"
      
      if not draftToSend?
        console.log "NO draftToSend - not callback so update the draft and save it"
        # need to update and save the draft state because reset below clears it
        @updateDraft()
        draftToSend = @currentEmailDraft
        
        @resetView()
        @hide()
      
      if @savingDraft
        console.log "SAVING DRAFT!!!!!!! do TIMEOUT callback!"
        # if still saving the draft from save_button click need to retry because otherwise multiple drafts
        # might be created or the wrong version of the draft might be sent.
        setTimeout (=>
         @sendEmail(draftToSend)
        ), 500
      else
        console.log "NOT in middle of draft save - saving it then sending"
        
        draftToSend.save(null, {
          success: (model, response, options) =>
            console.log "SAVED! setting draft_id to " + response.draft_id
            draftToSend.set("draft_id", response.draft_id)
            @trigger "change:draft", this
            
            @sendEmailDelayed(draftToSend)
        })
    else
      # easy case - no draft just send the email!
      console.log "NO draft! Sending"
      emailToSend = new TuringEmailApp.Models.Email()
      @updateEmail(emailToSend)
      @resetView()
      @hide()

      @sendEmailDelayed(emailToSend)
  
  sendEmailDelayed:(emailToSend) ->
    console.log "ComposeView sendEmailDelayed! - Setting up Undo button"
    @showEmailSentAlert(emailToSend.toJSON())
    
    TuringEmailApp.sendEmailTimeout = setTimeout (=>
      console.log "ComposeView sendEmailDelayed CALLBACK! doing send"
      @removeEmailSentAlert()
      
      if emailToSend.sendDraft?
        console.log "sendDraft!"
        emailToSend.sendDraft().done(->
          @trigger "change:draft", this
        )
      else
        console.log "send email!"
        emailToSend.sendEmail().fail(=>
          @sendEmailDelayedError(emailToSend.toJSON())
        )
    ), 5000

  sendEmailDelayedError:(emailToSendJSON) ->
    console.log "sendEmailDelayedError!!!"

    @loadEmail(emailToSendJSON)
    @show()

    $("#compose_form").prepend('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">
                                There was an error in sending your email!</div>')
