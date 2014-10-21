describe "ComposeView", ->
  beforeEach ->
    specStartTuringEmailApp()
    
    @composeView = TuringEmailApp.views.composeView

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@composeView.template).toEqual JST["backbone/templates/app/compose/modal_compose_view"]

  describe "after render", ->
    beforeEach ->
      @composeView.render()

    describe "#render", ->
      
      it "calls setupComposeView", ->
        spy = sinon.spy(@composeView, "setupComposeView")
        @composeView.render()
        expect(spy).toHaveBeenCalled()

    describe "#setupComposeView", ->

      it "binds the submit event to .compose_form", ->
        expect(@composeView.$el.find(".compose_form")).toHandle("submit")

      it "sends an email when the .compose_form is submitted", ->
        spy = sinon.spy(@composeView, "sendEmail")
        @composeView.$el.find(".compose_form").submit()
        expect(spy).toHaveBeenCalled()

      it "binds the click event to save button", ->
        expect(@composeView.$el.find(".compose_form #save_button")).toHandle("click")

      describe "when the save button is clicked", ->
        beforeEach ->
          @server = sinon.fakeServer.create()

        it "updates the draft", ->
          spy = sinon.spy(@composeView, "updateDraft")
          @composeView.$el.find(".compose_form #save_button").click()
          expect(spy).toHaveBeenCalled()

        describe "when the composeView is already saving the draft", ->

          it "if does not update the draft", ->
            @composeView.savingDraft = true
            spy = sinon.spy(@composeView, "updateDraft")
            @composeView.$el.find(".compose_form #save_button").click()
            expect(spy).not.toHaveBeenCalled()

        describe "when the server responds successfully", ->
          beforeEach ->
            @server.respondWith "POST", "/api/v1/email_accounts/drafts", JSON.stringify({})

          it "triggers change:draft", ->
            spy = sinon.backbone.spy(@composeView, "change:draft")
            @composeView.$el.find(".compose_form #save_button").click()
            @server.respond()
            expect(spy).toHaveBeenCalled()
            spy.restore()

          it "stops saving the draft", ->
            @composeView.$el.find(".compose_form #save_button").click()
            @server.respond()
            expect(@composeView.savingDraft).toEqual(false)

        describe "when the server responds unsuccessfully", ->

          it "stops saving the draft", ->
            @composeView.$el.find(".compose_form #save_button").click()
            @server.respond([404, {}, ""])
            expect(@composeView.savingDraft).toEqual(false)

      describe "when the compose modal is hidden", ->
        beforeEach ->
          @composeView.show()
          @clock = sinon.useFakeTimers()

        afterEach ->
          @clock.restore()

        it "saves the draft", ->
          @spy = sinon.spy(@composeView, "updateDraft")
          @composeView.hide()

          @clock.tick(1000)

          expect(@spy).toHaveBeenCalled()
          @spy.restore()

    describe "#show", ->

      it "shows the compose modal", ->
        @composeView.show()
        expect($("body")).toContain(".modal-backdrop.fade.in")

    describe "#hide", ->

      it "hides the compose modal", ->
        @composeView.hide()
        expect(@composeView.$el.find("#composeModal").hasClass("in")).toBeFalsy()

    describe "#showEmailSentAlert", ->
      
      describe "when the current alert token is defined", ->
        beforeEach ->
          @composeView.currentAlertToken = true

        it "should remove the alert", ->
          spy = sinon.spy(@composeView, "removeEmailSentAlert")
          @composeView.showEmailSentAlert()
          expect(spy).toHaveBeenCalled()

      it "should show the alert", ->
        spy = sinon.spy(TuringEmailApp, "showAlert")
        @composeView.showEmailSentAlert()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      it "should set the current alert token", ->
        @composeView.currentAlertToken = null
        @composeView.showEmailSentAlert()
        expect(@composeView.currentAlertToken).toBeDefined()

      it "binds the click event to undo email send button", ->
        expect($("#undo_email_send")).toHandle("click")

      describe "when the undo email send button is clicked", ->
        beforeEach ->
          @composeView.currentAlertToken = null
          emailJSON = {}
          @composeView.showEmailSentAlert(emailJSON)

        it "should remove the alert", ->
          spy = sinon.spy(@composeView, "removeEmailSentAlert")
          $("#undo_email_send").click()
          expect(spy).toHaveBeenCalled()

        it "should load the email", ->
          spy = sinon.spy(@composeView, "loadEmail")
          $("#undo_email_send").click()
          expect(spy).toHaveBeenCalled()

        it "show the compose modal", ->
          spy = sinon.spy(@composeView, "show")
          $("#undo_email_send").click()
          expect(spy).toHaveBeenCalled()

    describe "#removeEmailSentAlert", ->
      
      describe "when the current alert token is defined", ->
        beforeEach ->
          @composeView.currentAlertToken = true

        it "should remove the alert", ->
          spy = sinon.spy(TuringEmailApp, "removeAlert")
          @composeView.removeEmailSentAlert()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "should set the current alert token to be null", ->
          @composeView.removeEmailSentAlert()
          expect(@composeView.currentAlertToken is null).toBeTruthy()

    describe "#resetView", ->
      beforeEach ->
        @composeView.$el.find(".compose_form #to_input").val("This is the to input.")
        @composeView.$el.find(".compose_form #cc_input").val("This is the cc input.")
        @composeView.$el.find(".compose_form #bcc_input").val("This is the bcc input.")
        @composeView.$el.find(".compose_form #subject_input").val("This is the subject input.")
        @composeView.$el.find(".compose_form .note-editable").html("This is the compose email body.")

        @composeView.resetView()

      it "should clear the compose view input fields", ->
        expect(@composeView.$el.find(".compose_form #to_input").val()).toEqual ""
        expect(@composeView.$el.find(".compose_form #cc_input").val()).toEqual ""
        expect(@composeView.$el.find(".compose_form #bcc_input").val()).toEqual ""
        expect(@composeView.$el.find(".compose_form #subject_input").val()).toEqual ""
        expect(@composeView.$el.find(".compose_form .note-editable").html()).toEqual ""

      it "removes the email sent error alert", ->
        expect(@composeView.$el).not.toContainHtml('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">There was an error in sending your email!</div>')

        spy = sinon.spy(@composeView, "removeEmailSentAlert")
        @composeView.loadEmpty()
        expect(spy).toHaveBeenCalled()

      it "clears the current email draft and the email in reply to uid variables", ->
        expect(@composeView.currentEmailDraft).toEqual null
        expect(@composeView.emailInReplyToUID).toEqual null

    describe "#loadEmpty", ->

      it "resets the view", ->
        spy = sinon.spy(@composeView, "resetView")
        @composeView.loadEmpty()
        expect(spy).toHaveBeenCalled()

    describe "#loadEmail", ->

      it "resets the view", ->
        spy = sinon.spy(@composeView, "resetView")
        @composeView.loadEmail JSON.stringify({})
        expect(spy).toHaveBeenCalled()

      it "loads the email headers", ->
        spy = sinon.spy(@composeView, "loadEmailHeaders")
        emailJSON = {}
        @composeView.loadEmail emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

      it "loads the email body", ->
        spy = sinon.spy(@composeView, "loadEmailBody")
        emailJSON = {}
        @composeView.loadEmail emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

    describe "#loadEmailDraft", ->

      it "resets the view", ->
        spy = sinon.spy(@composeView, "resetView")
        @composeView.loadEmailDraft JSON.stringify({})
        expect(spy).toHaveBeenCalled()

      it "loads the email headers", ->
        spy = sinon.spy(@composeView, "loadEmailHeaders")
        emailJSON = {}
        @composeView.loadEmailDraft emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

      it "loads the email body", ->
        spy = sinon.spy(@composeView, "loadEmailBody")
        emailJSON = {}
        @composeView.loadEmailDraft emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

      it "creates a new current draft object with the passed in data", ->
        emailJSON = {}
        newEmailDraft = new TuringEmailApp.Models.EmailDraft(emailJSON)
        @composeView.loadEmailDraft emailJSON
        expect(@composeView.currentEmailDraft.attributes).toEqual newEmailDraft.attributes

      it "updates the emailThreadParent", ->
        emailJSON = {}
        emailThreadParent = {}
        @composeView.loadEmailDraft(emailJSON, emailThreadParent)
        expect(@composeView.emailThreadParent).toEqual(emailThreadParent)

    describe "#loadEmailAsReply", ->
      beforeEach ->
        @seededChance = new Chance(1)

      it "resets the view", ->
        spy = sinon.spy(@composeView, "resetView")
        @composeView.loadEmailAsReply JSON.stringify({})
        expect(spy).toHaveBeenCalled()

      it "loads the email body", ->
        spy = sinon.spy(@composeView, "loadEmailBody")
        emailJSON = {}
        @composeView.loadEmailAsReply emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

      describe "when there is a reply to address", ->

        it "updates the to input with the reply to address", ->
          emailJSON = {}
          emailJSON["reply_to_address"] = @seededChance.email()
          @composeView.loadEmailAsReply emailJSON
          expect(@composeView.$el.find(".compose_form #to_input").val()).toEqual emailJSON.reply_to_address

      describe "when there is not a reply to address", ->

        it "updates the to input with the from address", ->
          emailJSON = {}
          emailJSON["from_address"] = @seededChance.email()
          @composeView.loadEmailAsReply emailJSON
          expect(@composeView.$el.find(".compose_form #to_input").val()).toEqual emailJSON.from_address

      it "updates the subject input", ->
        emailJSON = {}
        emailJSON["subject"] = @seededChance.string({length: 20})
        @composeView.loadEmailAsReply emailJSON
        subjectWithPrefixFromEmail = @composeView.subjectWithPrefixFromEmail(emailJSON, "Re: ")
        expect(@composeView.$el.find(".compose_form #subject_input").val()).toEqual subjectWithPrefixFromEmail

      it "updates the email in reply to UID", ->
        emailJSON = {}
        emailJSON.uid = chance.integer({min: 1, max: 10000})
        @composeView.loadEmailAsReply emailJSON
        expect(@composeView.emailInReplyToUID).toEqual emailJSON.uid

    describe "#loadEmailAsForward", ->
      beforeEach ->
        @seededChance = new Chance(1)

      it "resets the view", ->
        spy = sinon.spy(@composeView, "resetView")
        @composeView.loadEmailAsForward JSON.stringify({})
        expect(spy).toHaveBeenCalled()

      it "updates the subject input", ->
        emailJSON = {}
        emailJSON["subject"] = @seededChance.string({length: 20})
        @composeView.loadEmailAsForward emailJSON
        subjectWithPrefixFromEmail = @composeView.subjectWithPrefixFromEmail(emailJSON, "Fwd: ")
        expect(@composeView.$el.find(".compose_form #subject_input").val()).toEqual subjectWithPrefixFromEmail

      it "loads the email body", ->
        spy = sinon.spy(@composeView, "loadEmailBody")
        emailJSON = {}
        @composeView.loadEmailAsForward emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

    describe "#loadEmailHeaders", ->
      beforeEach ->
        @seededChance = new Chance(1)

      it "updates the to input", ->
        emailJSON = {}
        emailJSON["tos"] = @seededChance.email()
        @composeView.loadEmailHeaders emailJSON
        expect(@composeView.$el.find(".compose_form #to_input").val()).toEqual emailJSON.tos

      it "updates the cc input", ->
        emailJSON = {}
        emailJSON["ccs"] = @seededChance.email()
        @composeView.loadEmailHeaders emailJSON
        expect(@composeView.$el.find(".compose_form #cc_input").val()).toEqual emailJSON.ccs

      it "updates the bcc input", ->
        emailJSON = {}
        emailJSON["bccs"] = @seededChance.email()
        @composeView.loadEmailHeaders emailJSON
        expect(@composeView.$el.find(".compose_form #bcc_input").val()).toEqual emailJSON.bccs

      it "updates the subject input", ->
        emailJSON = {}
        emailJSON["subject"] = @seededChance.string({length: 20})
        @composeView.loadEmailHeaders emailJSON
        subjectWithPrefixFromEmail = @composeView.subjectWithPrefixFromEmail(emailJSON)
        expect(@composeView.$el.find(".compose_form #subject_input").val()).toEqual subjectWithPrefixFromEmail

    describe "#parseEmail", ->
      beforeEach ->
        @seededChance = new Chance(1)
        
        @emailJSON = {}
        @emailJSON["date"] = "2014-09-18T21:28:48.000Z"
        @emailJSON["from_address"] =  @seededChance.email()

      describe "text", ->
        beforeEach ->
          @emailJSON["html_part"] = "<div>a\nb\nc\nd\n</div>"

          [@replyBody, @html] = @composeView.parseEmail(@emailJSON)

        it "parsed html", ->
          expect(@html).toBeTruthy()

      describe "text", ->
        beforeEach ->
          @emailJSON["text_part"] = "a\nb\nc\nd\n"

          [@replyBody, @html] = @composeView.parseEmail(@emailJSON)

        it "parsed plain text", ->
          expect(@html).toBeFalsy()
          
        it "adds > to the beginning of each line of the body", ->
          expect(@replyBody).toContain("> a\n> b\n> c\n> d\n> ")
        
    describe "#formatEmailReplyBody", ->
      beforeEach ->
        @seededChance = new Chance(1)
        
        @emailJSON = {}
        @emailJSON["date"] = "2014-09-18T21:28:48.000Z"
        @emailJSON["from_address"] =  @seededChance.email()

        tDate = new TDate()
        tDate.initializeWithISO8601(@emailJSON.date)
        
        @headerText = "\r\n\r\n"
        @headerText += tDate.longFormDateString() + ", " + @emailJSON.from_address + " wrote:"
        @headerText += "\r\n\r\n"
  
      describe "text", ->
        beforeEach ->
          @emailJSON["text_part"] = @seededChance.string({length: 250})
          
          @replyBody = @composeView.formatEmailReplyBody(@emailJSON)

        it "renders the reply header", ->
          expect(@replyBody.text()).toContain(@headerText)

      describe "html", ->
        beforeEach ->
          @emailJSON["html_part"] = "<div>" + @seededChance.string({length: 250}) + "</div>"
          @headerText = @headerText.replace(/\r\n/g, "<br>")

          @replyBody = @composeView.formatEmailReplyBody(@emailJSON)

        it "renders the reply header", ->
          expect(@replyBody.html()).toContain(@headerText)

    describe "#loadEmailBody", ->
      beforeEach ->
        @seededChance = new Chance(1)
        
        @formatEmailReplyBodySpy = sinon.spy(@composeView, "formatEmailReplyBody")
        @parseEmailSpy = sinon.spy(@composeView, "parseEmail")
        @htmlSpy = sinon.spy($.prototype, "html")
        
      afterEach ->
        @formatEmailReplyBodySpy.restore()
        @parseEmailSpy.restore()
        @htmlSpy.restore()

      describe "isReply=true", ->
        beforeEach ->
          @emailJSON = {}
          @emailJSON["text_part"] = @seededChance.string({length: 250})
          
          @body = @composeView.loadEmailBody(@emailJSON, true)
          
        it "loads the email body", ->
          expect(@formatEmailReplyBodySpy).toHaveBeenCalledWith(@emailJSON)
          expect(@htmlSpy).toHaveBeenCalledWith(@body)

      describe "isReply=false", ->
        describe "html=true", ->
          beforeEach ->
            @emailJSON = {}
            @emailJSON["html_part"] = "<div>" + @seededChance.string({length: 250}) + "</div>"
  
            @body = @composeView.loadEmailBody(@emailJSON, false)

          it "loads the email body", ->
            expect(@formatEmailReplyBodySpy).not.toHaveBeenCalled()
            expect(@parseEmailSpy).toHaveBeenCalled()
            expect(@htmlSpy).toHaveBeenCalledWith(@body)

        describe "html=false", ->
          beforeEach ->
            @emailJSON = {}
            @emailJSON["text_part"] = @seededChance.string({length: 250})
  
            @body = @composeView.loadEmailBody(@emailJSON, false)

          it "loads the email body", ->
            expect(@formatEmailReplyBodySpy).not.toHaveBeenCalled()
            expect(@parseEmailSpy).toHaveBeenCalled()
            expect(@htmlSpy).toHaveBeenCalledWith(@body)

    describe "#subjectWithPrefixFromEmail", ->
      beforeEach ->
        @seededChance = new Chance(1)

      it "returns the subject prefix if the email subject is not defined", ->
        emailJSON = {}
        subjectPrefix = "prefix"
        expect(@composeView.subjectWithPrefixFromEmail emailJSON, subjectPrefix).toEqual subjectPrefix

      it "strips Fwd: from the subject before prepending the subject prefix", ->
        emailJSON = {}
        subjectWithoutPrefix = @seededChance.string({length: 15})
        emailJSON["subject"] = "Fwd: " + subjectWithoutPrefix
        expect(@composeView.subjectWithPrefixFromEmail emailJSON).toEqual subjectWithoutPrefix

      it "strips Re: from the subject before prepending the subject prefix", ->
        emailJSON = {}
        subjectWithoutPrefix = @seededChance.string({length: 15})
        emailJSON["subject"] = "Re: " + subjectWithoutPrefix
        expect(@composeView.subjectWithPrefixFromEmail emailJSON).toEqual subjectWithoutPrefix

      it "prepends the subject prefix", ->
        emailJSON = {}
        subjectPrefix = "prefix"
        emailJSON["subject"] = @seededChance.string({length: 15})
        expect(@composeView.subjectWithPrefixFromEmail emailJSON, subjectPrefix).toEqual subjectPrefix + emailJSON["subject"]

    describe "#updateDraft", ->

      it "updates the email with the current email draft", ->
        @composeView.currentEmailDraft = new TuringEmailApp.Models.EmailDraft()
        spy = sinon.spy(@composeView, "updateEmail")
        @composeView.updateDraft()
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(@composeView.currentEmailDraft)

      it "creates a new email draft when the current email draft is not defined", ->
        @composeView.currentEmailDraft = null
        @composeView.updateDraft()
        anEmailDraft = new TuringEmailApp.Models.EmailDraft()
        @composeView.updateEmail(anEmailDraft)
        expect(@composeView.currentEmailDraft.attributes).toEqual anEmailDraft.attributes

    describe "#updateEmail", ->
      beforeEach ->
        @seededChance = new Chance(1)
        @email = new TuringEmailApp.Models.EmailDraft()

        @composeView.$el.find(".compose_form #to_input").val(@seededChance.email())
        @composeView.$el.find(".compose_form #cc_input").val(@seededChance.email())
        @composeView.$el.find(".compose_form #bcc_input").val(@seededChance.email())
        @composeView.$el.find(".compose_form #subject_input").val(@seededChance.string({length: 25}))
        @composeView.$el.find(".compose_form #compose_email_body").html(@seededChance.string({length: 250}))

        @composeView.emailInReplyToUID = chance.integer({min: 1, max: 10000})

        @composeView.updateEmail @email

      it "updates the email model with the email in reply to UID from the compose view", ->
        expect(@email.get("email_in_reply_to_uid")).toEqual @composeView.emailInReplyToUID

      it "updates the email model with the to input value from the compose form", ->
        expect(@email.get("tos")[0]).toEqual @composeView.$el.find(".compose_form #to_input").val()

      it "updates the email model with the cc input value from the compose form", ->
        expect(@email.get("ccs")[0]).toEqual @composeView.$el.find(".compose_form #cc_input").val()

      it "updates the email model with the bcc input value from the compose form", ->
        expect(@email.get("bccs")[0]).toEqual @composeView.$el.find(".compose_form #bcc_input").val()

      it "updates the email model with the subject input value from the compose form", ->
        expect(@email.get("subject")).toEqual @composeView.$el.find(".compose_form #subject_input").val()

      it "updates the email model with the html input value from the compose form", ->
        expect(@email.get("html_part")).toEqual @composeView.$el.find(".compose_form .note-editable").html()

      it "updates the email model with the text input value from the compose form", ->
        expect(@email.get("text_part")).toEqual @composeView.$el.find(".compose_form .note-editable").text()

    describe "sendEmail", ->

      describe "when the current email draft is defined", ->
        beforeEach ->
          @composeView.currentEmailDraft = new TuringEmailApp.Models.EmailDraft()

        it "updates the draft", ->
          spy = sinon.spy(@composeView, "updateDraft")
          @composeView.$el.find(".compose_form #save_button").click()
          expect(spy).toHaveBeenCalled()

        it "resets the view", ->
          spy = sinon.spy(@composeView, "resetView")
          @composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

        it "hides the compose modal", ->
          spy = sinon.spy(@composeView, "hide")
          @composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

        describe "when saving the draft", ->
          beforeEach ->
            @composeView.savingDraft = true
            @clock = sinon.useFakeTimers()

          afterEach ->
            @clock.restore()

          it "sends the email after a timeout", ->
            @spy = sinon.spy(@composeView, "sendEmail")
            @composeView.sendEmail()

            @clock.tick(500)

            expect(@spy).toHaveBeenCalledTwice()

            @composeView.savingDraft = false

        describe "when not saving the draft", ->
          beforeEach ->
            @composeView.savingDraft = false
            @server = sinon.fakeServer.create()

          describe "when the server responds successfully", ->
            beforeEach ->
              @server.respondWith "POST", "/api/v1/email_accounts/drafts", JSON.stringify({})

            it "triggers change:draft", ->
              spy = sinon.backbone.spy(@composeView, "change:draft")
              @composeView.sendEmail()
              @server.respond()
              expect(spy).toHaveBeenCalled()
              spy.restore()

      describe "when the current email draft is not defined", ->
        beforeEach ->
          @composeView.currentEmailDraft = null

        it "updates the email", ->
          spy = sinon.spy(@composeView, "updateEmail")
          @composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

        it "resets the view", ->
          spy = sinon.spy(@composeView, "resetView")
          @composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

        it "hides the compose modal", ->
          spy = sinon.spy(@composeView, "hide")
          @composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

        it "sends the email after a delay", ->
          spy = sinon.spy(@composeView, "sendEmailDelayed")
          @composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

    describe "#sendEmailDelayed", ->
      beforeEach ->
        @email = new TuringEmailApp.Models.EmailDraft()

      it "shows the email sent alert", ->
        spy = sinon.spy(@composeView, "showEmailSentAlert")
        @composeView.sendEmailDelayed @email
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(@email.toJSON())

      it "removes the email sent alert", ->
        @clock = sinon.useFakeTimers()
        @spy = sinon.spy(@composeView, "removeEmailSentAlert")
        @composeView.sendEmailDelayed @email

        @clock.tick(5000)

        expect(@spy).toHaveBeenCalled()
        @clock.restore()

      describe "when send draft is defined", ->
        beforeEach ->
          @server = sinon.fakeServer.create()
          @server.respondWith "POST", "/api/v1/email_accounts/send_draft", JSON.stringify({})
          @clock = sinon.useFakeTimers()

        afterEach ->
          @clock.restore()

        it "should send the draft", ->
          @spy = sinon.spy(@email, "sendDraft")
          @composeView.sendEmailDelayed @email
          @server.respond()

          @clock.tick(5000)

          expect(@spy).toHaveBeenCalled()

        it "triggers change:draft upon being done", ->
          @spySendDraft = sinon.spy(@email, "sendDraft")
          @spyChangeDraft = sinon.backbone.spy(@composeView, "change:draft")
          @composeView.sendEmailDelayed @email

          @clock.tick(5000)
          
          expect(@spySendDraft).toHaveBeenCalled()
          @server.respond()
          expect(@spyChangeDraft).toHaveBeenCalled()

      describe "when send draft is not defined", ->
        beforeEach ->
          @server = sinon.fakeServer.create()
          @email.sendDraft = null
          @clock = sinon.useFakeTimers()

        afterEach ->
          @clock.restore()

        it "should send the email", ->
          @spy = sinon.spy(@email, "sendEmail")
          @composeView.sendEmailDelayed @email

          @clock.tick(5000)

          expect(@spy).toHaveBeenCalled()

        it "should should send the email after a delay if the initial sending doesn't work", ->
          @spySendEmail = sinon.spy(@email, "sendEmail")
          @spySendEmailDelayedError = sinon.spy(@composeView, "sendEmailDelayedError")
          @composeView.sendEmailDelayed @email

          @clock.tick(5000)

          expect(@spySendEmail).toHaveBeenCalled()
          @server.respond()
          expect(@spySendEmailDelayedError).toHaveBeenCalled()

    describe "#sendEmailDelayedError", ->

      it "loads the email", ->
        spy = sinon.spy(@composeView, "show")
        emailJSON = {}
        @composeView.sendEmailDelayedError emailJSON
        expect(spy).toHaveBeenCalled()

      it "show the compose modal", ->
        spy = sinon.spy(@composeView, "show")
        @composeView.sendEmailDelayedError JSON.stringify({})
        expect(spy).toHaveBeenCalled()

      it "alert the user that an error occurred", ->
        @composeView.sendEmailDelayedError JSON.stringify({})
        expect(@composeView.$el).toContainHtml('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">
                                There was an error in sending your email!</div>')