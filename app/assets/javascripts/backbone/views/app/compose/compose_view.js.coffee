TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.ComposeView extends Backbone.View
  template: JST["backbone/templates/app/compose/modal_compose"]

  initialize: (options) ->
    @app = options.app
  
  render: ->
    @$el.html(@template())
    
    @setupComposeView()
    @setupSendAndArchive()
    # @setupLinkPreviews()
    @setupEmailTagsDropdown()
    @setupEmailTemplatesDropdown()

    @$el.find(".send-later-datetimepicker").datetimepicker(
      format: "m/d/Y g:i a"
      formatTime: "g:i a"
    );

    @$el.find(".tracking-switch").bootstrapSwitch()

    return this

  #######################
  ### Setup Functions ###
  #######################

  setupComposeView: ->
    config = {}
    config.toolbar = [
      {
        name: "basicstyles"
        groups: [
          "basicstyles"
          "cleanup"
        ]
        items: [
          "Bold"
          "Italic"
          "Underline"
          "Strike"
          "Subscript"
          "Superscript"
        ]
      }
      {
        name: "paragraph"
        groups: [
          "list"
          "indent"
          "blocks"
          "align"
          "bidi"
        ]
        items: [
          "NumberedList"
          "BulletedList"
          "-"
          "Outdent"
          "Indent"
          "-"
          "JustifyLeft"
          "JustifyCenter"
          "JustifyRight"
          "JustifyBlock"
        ]
      }
      {
        name: "links"
        items: [
          "Link"
          "Unlink"
        ]
      }
      {
        name: "insert"
        items: [
          "Smiley"
        ]
      }
      {
        name: "styles"
        items: [
          "Font"
          "FontSize"
        ]
      }
      {
        name: "colors"
        items: [
          "TextColor"
          "BGColor"
        ]
      }
      {
        name: "document"
        groups: [
          "mode"
          "document"
          "doctools"
        ]
        items: [
          "Source"
          "-"
          "Print"
        ]
      }
      {
        name: "clipboard"
        groups: [
          "clipboard"
          "undo"
        ]
        items: [
          "Cut"
          "Copy"
          "Paste"
          "-"
          "Undo"
          "Redo"
        ]
      }
      {
        name: "tools"
        items: [
          "Maximize"
        ]
      }
    ]
    config.toolbarGroups = [
      {
        name: "basicstyles"
        groups: [
          "basicstyles"
          "cleanup"
        ]
      }
      {
        name: "paragraph"
        groups: [
          "list"
          "indent"
          "blocks"
          "align"
          "bidi"
        ]
      }
      {
        name: "links"
      }
      {
        name: "insert"
      }
      {
        name: "styles"
      }
      {
        name: "colors"
      }
      {
        name: "document"
        groups: [
          "mode"
          "document"
          "doctools"
        ]
      }
      {
        name: "clipboard"
        groups: [
          "clipboard"
          "undo"
        ]
      }
      {
        name: "tools"
      }
    ]

    @$el.find(".compose-email-body").ckeditor config

    @$el.find(".compose-form").submit =>
      console.log "SEND clicked! Sending..."
      @sendEmail()
      return false

    @$el.find(".compose-form .send-later-button").click =>
      @sendEmailDelayed()
      
    @$el.find(".compose-form .save-button").click =>
      @saveDraft(true)

    @$el.find(".compose-modal").on "hidden.bs.modal", (event) =>
      @saveDraft(false)

  setupSendAndArchive: ->
    @$el.find(".send-and-archive").click ->
      console.log "Send and archive clicked"

  setupLinkPreviews: ->
    @$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").bind "keydown", "space return shift+return", =>
      emailHtml = @$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").html()
      indexOfUrl = emailHtml.search(/((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/)

      linkPreviewIndex = emailHtml.search("compose-link-preview")

      if indexOfUrl isnt -1 and linkPreviewIndex is -1
        link = emailHtml.substring(indexOfUrl)?.split(" ")?[0]

        websitePreview = new TuringEmailApp.Models.WebsitePreview(
          websiteURL: link
        )

        @websitePreviewView = new TuringEmailApp.Views.App.WebsitePreviewView(
          model: websitePreview
          el: @$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable")
        )
        websitePreview.fetch()

  setupEmojis: ->
    @emojiDropdownView = new TuringEmailApp.Views.App.EmojiDropdownView(
      el: @$el.find(".note-toolbar.btn-toolbar")
    )
    @emojiDropdownView.render()

    noteEditable = @$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable")
    @$el.find(".emoji-dropdown span").click ->
      noteEditable.append($(@).html())

  setupEmailTemplatesDropdown: ->
    @emailTemplatesDropdownView = new TuringEmailApp.Views.App.EmailTemplatesDropdownView(
      el: @$el.find(".send-later-button")
      composeView: @
    )
    @emailTemplatesDropdownView.render()

  setupEmailTagsDropdown: ->
    @emailTagDropdownView = new TuringEmailApp.Views.App.EmailTagDropdownView(
      el: @$el.find(".note-toolbar.btn-toolbar")
      composeView: @
    )
    @emailTagDropdownView.render()

  #########################
  ### Display Functions ###
  #########################

  show: ->
    @$el.find(".compose-modal").modal "show"
    
  hide: ->
    @$el.find(".compose-modal").modal "hide"

  resetView: ->
    console.log("ComposeView RESET!!")

    @$el.find(".compose-form #email_sent_error_alert").remove()
    @removeEmailSentAlert()

    @currentEmailDraft = null
    @emailInReplyToUID = null
    @emailThreadParent = null

    @$el.find(".compose-form .to-input").val("")
    @$el.find(".compose-form .cc-input").val("")
    @$el.find(".compose-form .bcc-input").val("")

    @$el.find(".compose-form .subject-input").val("")
    @$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").html(" ")
    @$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").text(" ")

    @$el.find(".compose-form .send-later-datetimepicker").val("")

  showEmailSentAlert: (emailSentJSON) ->
    console.log "ComposeView showEmailSentAlert"
    
    @removeEmailSentAlert() if @currentAlertToken?
    
    @currentAlertToken = @app.showAlert('Your message has been sent. <span class="undo-email-send">Undo</span>', "alert-info")
    $(".undo-email-send").click =>
      clearTimeout(TuringEmailApp.sendEmailTimeout)
      
      @removeEmailSentAlert()
      @loadEmail(emailSentJSON)
      @show()
  
  removeEmailSentAlert: ->
    console.log "ComposeView REMOVE emailSentAlert"

    if @currentAlertToken?
      @app.removeAlert(@currentAlertToken)
      @currentAlertToken = null

  ############################
  ### Load Email Functions ###
  ############################

  loadEmpty: ->
    @resetView()

  loadEmail: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmail!!")
    @resetView()

    @loadEmailHeaders(emailJSON)
    @loadEmailBody(emailJSON)

    @emailThreadParent = emailThreadParent

  loadEmailDraft: (emailDraftJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailDraft!!")
    @resetView()

    @loadEmailHeaders(emailDraftJSON)
    @loadEmailBody(emailDraftJSON)

    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft(emailDraftJSON)
    @emailThreadParent = emailThreadParent

  loadEmailAsReply: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailAsReply!!")
    @resetView()

    @$el.find(".compose-form .to-input").val(if emailJSON.reply_to_address? then emailJSON.reply_to_address else emailJSON.from_address)
    @$el.find(".compose-form .subject-input").val(@subjectWithPrefixFromEmail(emailJSON, "Re: "))
    @loadEmailBody(emailJSON, true)

    @emailInReplyToUID = emailJSON.uid
    @emailThreadParent = emailThreadParent

  loadEmailAsForward: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailAsForward!!")
    @resetView()

    @$el.find(".compose-form .subject-input").val(@subjectWithPrefixFromEmail(emailJSON, "Fwd: "))
    @loadEmailBody(emailJSON, true)

    @emailThreadParent = emailThreadParent

  loadEmailHeaders: (emailJSON) ->
    console.log("ComposeView loadEmailHeaders!!")
    @$el.find(".compose-form .to-input").val(emailJSON.tos)
    @$el.find(".compose-form .cc-input").val(emailJSON.ccs)
    @$el.find(".compose-form .bcc-input").val(emailJSON.bccs)

    @$el.find(".compose-form .subject-input").val(@subjectWithPrefixFromEmail(emailJSON))

  loadEmailBody: (emailJSON, isReply=false) ->
    console.log("ComposeView loadEmailBody!!")

    if isReply
      body = @formatEmailReplyBody(emailJSON)
    else
      [body, html] = @parseEmail(emailJSON)
      body = $.parseHTML(body) if not html

    @$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").html(body)

    return body

  parseEmail: (emailJSON) ->
    htmlFailed = true

    if emailJSON.html_part?
      try
        emailHTML = $($.parseHTML(emailJSON.html_part))

        if emailHTML.length is 0 || not emailHTML[0].nodeName.match(/body/i)?
          body = $("<div />")
          body.html(emailHTML)
        else
          body = emailHTML

        htmlFailed = false
      catch error
        console.log error
        htmlFailed = true

    if htmlFailed
      bodyText = ""

      text = ""
      if emailJSON.text_part?
        text = emailJSON.text_part
      else if emailJSON.body_text?
        text = emailJSON.body_text

      for line in text.split("\n")
        bodyText += "> " + line + "\n"

      body = bodyText

    return [body, !htmlFailed]

  ##############################
  ### Format Email Functions ###
  ##############################

  formatEmailReplyBody: (emailJSON) ->
    tDate = new TDate()
    tDate.initializeWithISO8601(emailJSON.date)

    headerText = "\r\n\r\n"
    headerText += tDate.longFormDateString() + ", " + emailJSON.from_address + " wrote:"
    headerText += "\r\n\r\n"

    headerText = headerText.replace(/\r\n/g, "<br />")

    [body, html] = @parseEmail(emailJSON)

    if html
      $(body[0]).prepend(headerText)
    else
      body = body.replace(/\r\n/g, "<br />")
      body = $($.parseHTML(headerText + body))

    return body

  subjectWithPrefixFromEmail: (emailJSON, subjectPrefix="") ->
    console.log("ComposeView subjectWithPrefixFromEmail")
    return subjectPrefix if not emailJSON.subject

    subjectWithoutForwardPrefix = emailJSON.subject.replace("Fwd: ", "")
    subjectWithoutForwardAndReplyPrefixes = subjectWithoutForwardPrefix.replace("Re: ", "")
    return subjectPrefix + subjectWithoutForwardAndReplyPrefixes

  ###################
  ### Email State ###
  ###################
    
  updateDraft: ->
    console.log "ComposeView updateDraft!"
    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft() if not @currentEmailDraft?
    @updateEmail(@currentEmailDraft)

  updateEmail: (email) ->
    console.log "ComposeView updateEmail!"
    email.set("email_in_reply_to_uid", @emailInReplyToUID)
    email.set("tracking_enabled", @$el.find(".compose-form .tracking-switch").parent().parent().hasClass("switch-on"))

    email.set("tos", @$el.find(".compose-form .to-input").val().split(/[;, ]/))
    email.set("ccs", @$el.find(".compose-form .cc-input").val().split(/[;, ]/))
    email.set("bccs",  @$el.find(".compose-form .bcc-input").val().split(/[;, ]/))

    email.set("subject", @$el.find(".compose-form .subject-input").val())
    email.set("html_part", @$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").html())
    email.set("text_part", @$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").text())
    
  emailHasRecipients: (email) ->
    return email.get("tos").length > 1 || email.get("tos")[0].trim() != "" ||
           email.get("ccs").length > 1 || email.get("ccs")[0].trim() != "" ||
           email.get("bccs").length > 1 || email.get("bccs")[0].trim() != ""

  ###################
  ### Email Draft ###
  ###################
    
  saveDraft: (force = false) ->
    console.log "SAVE clicked - saving the draft!"

    # if already in the middle of saving, no reason to save again
    # it could be an error to save again if the draft_id isn't set because it would create duplicate drafts
    if @savingDraft
      console.log "SKIPPING SAVE - already saving!!"
      return

    @updateDraft()

    if !force &&
       !@emailHasRecipients(@currentEmailDraft) &&
       @currentEmailDraft.get("subject") == "" &&
       @currentEmailDraft.get("html_part") == "" && @currentEmailDraft.get("text_part") == "" &&
       not @currentEmailDraft.get("draft_id")?

      console.log "SKIPPING SAVE - BLANK draft!!"
    else
      @savingDraft = true

      @currentEmailDraft.save(null,
        success: (model, response, options) =>
          console.log "SAVED! setting draft_id to " + response.draft_id

          model.set("draft_id", response.draft_id)
          @trigger "change:draft", this, model, @emailThreadParent

          @savingDraft = false

        error: (model, response, options) =>
          console.log "SAVE FAILED!!!"
          @savingDraft = false
      )

  ##################
  ### Send Email ###
  ##################
    
  sendEmail: (draftToSend=null) ->
    console.log "ComposeView sendEmail!"
    
    if @currentEmailDraft? || draftToSend?
      console.log "sending DRAFT"
      
      if not draftToSend?
        console.log "NO draftToSend - not callback so update the draft and save it"
        # need to update and save the draft state because reset below clears it
        @updateDraft()
        draftToSend = @currentEmailDraft
        
        if !@emailHasRecipients(draftToSend)
          @app.showAlert("Email has no recipients!", "alert-danger", 5000)
          return
        
        @resetView()
        @hide()
        
      if @savingDraft
        console.log "SAVING DRAFT!!!!!!! do TIMEOUT callback!"
        # if still saving the draft from save-button click need to retry because otherwise multiple drafts
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
            @trigger "change:draft", this, model, @emailThreadParent
            
            @sendUndoableEmail(draftToSend)
        })
    else
      # easy case - no draft just send the email!
      console.log "NO draft! Sending"
      emailToSend = new TuringEmailApp.Models.Email()
      @updateEmail(emailToSend)

      if !@emailHasRecipients(emailToSend)
        @app.showAlert("Email has no recipients!", "alert-danger", 5000)
        return
      
      @resetView()
      @hide()

      @sendUndoableEmail(emailToSend)

  sendEmailDelayed: (draftToSend=null) ->
    console.log "sendEmailDelayed!!!"
    
    dateTimePickerVal = @$el.find(".compose-modal .send-later-datetimepicker").val()
    sendAtDateTime = new Date(dateTimePickerVal)
      
    if sendAtDateTime.toString() == "Invalid Date"
      @app.showAlert("The send later date is invalid.", "alert-danger", 5000)
      return
    else if sendAtDateTime < new Date()
      @app.showAlert("The send later date is before the current time.", "alert-danger", 5000)
      return

    if @currentEmailDraft? || draftToSend?
      console.log "sending DRAFT later"

      if not draftToSend?
        console.log "NO draftToSend - not callback so update the draft and save it"
        # need to update and save the draft state because reset below clears it
        @updateDraft()
        draftToSend = @currentEmailDraft
        if !@emailHasRecipients(draftToSend)
          @app.showAlert("Email has no recipients!", "alert-danger", 5000)
          return

        @resetView()
        @hide()

      if @savingDraft
        console.log "SAVING DRAFT!!!!!!! do sendEmailDelayed TIMEOUT callback!"
        # if still saving the draft from save-button click need to retry because otherwise multiple drafts
        # might be created or the wrong version of the draft might be sent.
        setTimeout (=>
          @sendEmailDelayed(draftToSend)
        ), 500
      else
        console.log "NOT in middle of draft save - sending later now!!"
        
        draftToSend.sendLater(sendAtDateTime).done(
          => @trigger "change:draft", this, model, @emailThreadParent
        )
    else
      # easy case - no draft just send the email!
      console.log "NO draft! Sending later now!!"
      emailToSend = new TuringEmailApp.Models.Email()
      @updateEmail(emailToSend)

      if !@emailHasRecipients(emailToSend)
        @app.showAlert("Email has no recipients!", "alert-danger", 5000)
        return

      @resetView()
      @hide()
      
      emailToSend.sendLater(sendAtDateTime)
      
  sendUndoableEmail: (emailToSend) ->
    console.log "ComposeView sendUndoableEmail! - Setting up Undo button"
    @showEmailSentAlert(emailToSend.toJSON())

    TuringEmailApp.sendEmailTimeout = setTimeout (=>
      console.log "ComposeView sendUndoableEmail CALLBACK! doing send"
      @removeEmailSentAlert()

      if emailToSend instanceof TuringEmailApp.Models.EmailDraft
        console.log "sendDraft!"
        emailToSend.sendDraft(
          @app
          =>
            @trigger "change:draft", this, emailToSend, @emailThreadParent
          =>
            @sendUndoableEmailError(emailToSend.toJSON())
        )
      else
        console.log "send email!"
        emailToSend.sendEmail().done(=>
          @trigger "change:draft", this, emailToSend, @emailThreadParent
        ).fail(=>
          @sendUndoableEmailError(emailToSend.toJSON())
        )
    ), 5000

  sendUndoableEmailError: (emailToSendJSON) ->
    console.log "sendUndoableEmailError!!!"

    @loadEmail(emailToSendJSON, @emailThreadParent)
    @show()

    @$el.find(".compose-form").prepend('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">
                                There was an error in sending your email!</div>')
