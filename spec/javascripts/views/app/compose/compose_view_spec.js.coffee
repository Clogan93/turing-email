describe "ComposeView", ->
  beforeEach ->
    specStartTuringEmailApp()
    
    @composeView = TuringEmailApp.views.composeView

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@composeView.template).toEqual JST["backbone/templates/app/compose/modal_compose"]

  describe "#render", ->
    beforeEach ->
      @setupComposeViewStub = sinon.stub(@composeView, "setupComposeView")
      @setupLinkPreviewsStub = sinon.stub(@composeView, "setupLinkPreviews")
      @setupEmojisStub = sinon.stub(@composeView, "setupEmojis")
      
      @datetimepickerStub = sinon.stub($.fn, "datetimepicker", ->)
      
      @composeView.render()
      
    afterEach ->
      @setupComposeViewStub.restore()
      @setupLinkPreviewsStub.restore()
      @setupEmojisStub.restore()
      
      @datetimepickerStub.restore()
      
    it "calls setupComposeView", ->
      expect(@setupComposeViewStub).toHaveBeenCalled()

    # it "calls setupLinkPreviews", ->
    #   expect(@setupLinkPreviewsStub).toHaveBeenCalled()

    # it "calls setupEmojis", ->
    #   expect(@setupEmojisStub).toHaveBeenCalled()
      
    it "calls datetimepicker", ->
      expect(@datetimepickerStub).toHaveBeenCalledWith(format: "m/d/Y g:i a", formatTime: "g:i a")
    
  describe "after render", ->
    beforeEach ->
      @composeView.render()

    describe "Setup Functions", ->
      describe "#setupComposeView", ->
        it "sends an email when the .compose-form is submitted", ->
          sendEmailStub = sinon.stub(@composeView, "sendEmail", ->)
          @composeView.$el.find(".compose-form").submit()
          expect(sendEmailStub).toHaveBeenCalled()
          sendEmailStub.restore()
  
        it "sends a delayed email when the send later button is clicked", ->
          sendEmailDelayedStub = sinon.stub(@composeView, "sendEmailDelayed", ->)
          @composeView.$el.find(".compose-form .send-later-button").click()
          expect(sendEmailDelayedStub).toHaveBeenCalled()
          sendEmailDelayedStub.restore()
  
        it "saves the draft when the save button is clicked", ->
          saveDraft = sinon.stub(@composeView, "saveDraft", ->)
          @composeView.$el.find(".compose-form .save-button").click()
          expect(saveDraft).toHaveBeenCalledWith(true)
          saveDraft.restore()
  
        it "saves the draft when the compose dialog is hidden", ->
          saveDraft = sinon.stub(@composeView, "saveDraft", ->)
          @composeView.$el.find(".compose-modal").trigger("hidden.bs.modal")
          expect(saveDraft).toHaveBeenCalledWith(false)
          saveDraft.restore()
  
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
  
      # describe "#setupLinkPreviews", ->
      #   it "binds keydown to the compose body", ->
      #     expect(@composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable")).toHandle("keydown")
  
      #   describe "when text is entered in the compose body", ->
      #     describe "when there is no link", ->
  
      #       it "does not create the website preview view", ->
      #         @composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").html("hello world")
      #         expect(@composeView.websitePreviewView).not.toBeDefined()
  
      #     describe "when there is a link", ->
      #       it "create the website preview view", ->
      #         @composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").html("this is a test http://www.apple.com")
  
      #         @event = jQuery.Event("keydown")
      #         @event.which = $.ui.keyCode.SPACE
      #         @composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").trigger(@event)
  
      #         websitePreviewAttributes = FactoryGirl.create("WebsitePreview")
      #         @composeView.websitePreviewView.model.set(websitePreviewAttributes.toJSON())
  
      #         expect(@composeView.websitePreviewView).toBeDefined()
      #         expect(@composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable")).toContain($(".compose-link-preview"))

      # describe "#setupEmojis", ->
      #   beforeEach ->
      #     window.TestEmoji = true
          
      #     @composeView.emojiDropdownView = null
      #     @composeView.setupEmojis()
  
      #   afterEach ->
      #     window.TestEmoji = false
          
      #   it "creates an emoji dropdown view", ->
      #     expect(@composeView.emojiDropdownView).toBeDefined()
  
      #   it "renders the emoji dropdown view onto the compose toolbar view", ->
      #     expect(@composeView.$el.find(".note-toolbar.btn-toolbar")).toContain($(".emoji-dropdown-div"))
  
      #   it "attaches click handlers to the emojis in the dropdown", ->
      #     expect(@composeView.$el.find(".emoji-dropdown span")).toHandle("click")
  
      #   describe "when one of the emojis is clicked", ->
      #     beforeEach ->
      #       @anEmoji = @composeView.$el.find(".emoji-dropdown span").first()
      #       @anEmoji.click()
  
      #     it "renders the emoji into the compose email body input", ->
      #       expect(@composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable")).toContain($(".emoji"))
      #       expect(@composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable")).toContain($(".emoji"))
              
    describe "Display Functions", ->
      describe "#show", ->
        it "shows the compose modal", ->
          @composeView.show()
          expect($("body")).toContain(".modal-backdrop.fade.in")
  
      describe "#hide", ->
        it "hides the compose modal", ->
          @composeView.hide()
          expect(@composeView.$el.find(".compose-modal").hasClass("in")).toBeFalsy()
  
      describe "#resetView", ->
        beforeEach ->
          @composeView.$el.find(".compose-form .to-input").val("This is the to input.")
          @composeView.$el.find(".compose-form .cc-input").val("This is the cc input.")
          @composeView.$el.find(".compose-form .bcc-input").val("This is the bcc input.")
          @composeView.$el.find(".compose-form .subject-input").val("This is the subject input.")
          @composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").html("This is the compose email body.")
          @composeView.$el.find(".compose-form .send-later-datetimepicker").val("Date")
  
          @composeView.resetView()
  
        it "should clear the compose view input fields", ->
          expect(@composeView.$el.find(".compose-form .to-input").val()).toEqual ""
          expect(@composeView.$el.find(".compose-form .cc-input").val()).toEqual ""
          expect(@composeView.$el.find(".compose-form .bcc-input").val()).toEqual ""
          expect(@composeView.$el.find(".compose-form .subject-input").val()).toEqual ""
          expect(@composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").length).toEqual 0
          expect(@composeView.$el.find(".compose-form .send-later-datetimepicker").val()).toEqual ""
  
        it "removes the email sent error alert", ->
          expect(@composeView.$el).not.toContainHtml('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">There was an error in sending your email!</div>')
  
          spy = sinon.spy(@composeView, "removeEmailSentAlert")
          @composeView.loadEmpty()
          expect(spy).toHaveBeenCalled()
          spy.restore()
  
        it "clears the current email draft and the email in reply to uid variables", ->
          expect(@composeView.currentEmailDraft).toEqual null
          expect(@composeView.emailInReplyToUID).toEqual null
  
      describe "#showEmailSentAlert", ->
        describe "when the current alert token is defined", ->
          beforeEach ->
            @composeView.currentAlertToken = true
  
          it "should remove the alert", ->
            spy = sinon.spy(@composeView, "removeEmailSentAlert")
            @composeView.showEmailSentAlert()
            expect(spy).toHaveBeenCalled()
            spy.restore()
  
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
          expect($(".undo-email-send")).toHandle("click")
  
        describe "when the undo email send button is clicked", ->
          beforeEach ->
            @composeView.currentAlertToken = null
            emailJSON = {}
            @composeView.showEmailSentAlert(emailJSON)
  
          it "should remove the alert", ->
            spy = sinon.spy(@composeView, "removeEmailSentAlert")
            $(".undo-email-send").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()
  
          it "should load the email", ->
            spy = sinon.spy(@composeView, "loadEmail")
            $(".undo-email-send").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()
  
          it "show the compose modal", ->
            spy = sinon.spy(@composeView, "show")
            $(".undo-email-send").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()
  
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

    describe "Load Email Functions", ->
      describe "#loadEmpty", ->
        it "resets the view", ->
          spy = sinon.spy(@composeView, "resetView")
          @composeView.loadEmpty()
          expect(spy).toHaveBeenCalled()
          spy.restore()
          
      describe "#loadEmail", ->
        it "resets the view", ->
          spy = sinon.spy(@composeView, "resetView")
          @composeView.loadEmail JSON.stringify({})
          expect(spy).toHaveBeenCalled()
          spy.restore()
  
        it "loads the email headers", ->
          spy = sinon.spy(@composeView, "loadEmailHeaders")
          emailJSON = {}
          @composeView.loadEmail emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()
  
        it "loads the email body", ->
          spy = sinon.spy(@composeView, "loadEmailBody")
          emailJSON = {}
          @composeView.loadEmail emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()

      describe "#loadEmailDraft", ->
        it "resets the view", ->
          spy = sinon.spy(@composeView, "resetView")
          @composeView.loadEmailDraft JSON.stringify({})
          expect(spy).toHaveBeenCalled()
          spy.restore()
  
        it "loads the email headers", ->
          spy = sinon.spy(@composeView, "loadEmailHeaders")
          emailJSON = {}
          @composeView.loadEmailDraft emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()
  
        it "loads the email body", ->
          spy = sinon.spy(@composeView, "loadEmailBody")
          emailJSON = {}
          @composeView.loadEmailDraft emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()
  
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
          spy.restore()
  
        it "loads the email body", ->
          spy = sinon.spy(@composeView, "loadEmailBody")
          emailJSON = {}
          @composeView.loadEmailAsReply emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()
  
        describe "when there is a reply to address", ->
  
          it "updates the to input with the reply to address", ->
            emailJSON = {}
            emailJSON["reply_to_address"] = @seededChance.email()
            @composeView.loadEmailAsReply emailJSON
            expect(@composeView.$el.find(".compose-form .to-input").val()).toEqual emailJSON.reply_to_address
  
        describe "when there is not a reply to address", ->
  
          it "updates the to input with the from address", ->
            emailJSON = {}
            emailJSON["from_address"] = @seededChance.email()
            @composeView.loadEmailAsReply emailJSON
            expect(@composeView.$el.find(".compose-form .to-input").val()).toEqual emailJSON.from_address
  
        it "updates the subject input", ->
          emailJSON = {}
          emailJSON["subject"] = @seededChance.string({length: 20})
          @composeView.loadEmailAsReply emailJSON
          subjectWithPrefixFromEmail = @composeView.subjectWithPrefixFromEmail(emailJSON, "Re: ")
          expect(@composeView.$el.find(".compose-form .subject-input").val()).toEqual subjectWithPrefixFromEmail
  
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
          spy.restore()
  
        it "updates the subject input", ->
          emailJSON = {}
          emailJSON["subject"] = @seededChance.string({length: 20})
          @composeView.loadEmailAsForward emailJSON
          subjectWithPrefixFromEmail = @composeView.subjectWithPrefixFromEmail(emailJSON, "Fwd: ")
          expect(@composeView.$el.find(".compose-form .subject-input").val()).toEqual subjectWithPrefixFromEmail
  
        it "loads the email body", ->
          spy = sinon.spy(@composeView, "loadEmailBody")
          emailJSON = {}
          @composeView.loadEmailAsForward emailJSON
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailJSON)
          spy.restore()
  
      describe "#loadEmailHeaders", ->
        beforeEach ->
          @seededChance = new Chance(1)
  
        it "updates the to input", ->
          emailJSON = {}
          emailJSON["tos"] = @seededChance.email()
          @composeView.loadEmailHeaders emailJSON
          expect(@composeView.$el.find(".compose-form .to-input").val()).toEqual emailJSON.tos
  
        it "updates the cc input", ->
          emailJSON = {}
          emailJSON["ccs"] = @seededChance.email()
          @composeView.loadEmailHeaders emailJSON
          expect(@composeView.$el.find(".compose-form .cc-input").val()).toEqual emailJSON.ccs
  
        it "updates the bcc input", ->
          emailJSON = {}
          emailJSON["bccs"] = @seededChance.email()
          @composeView.loadEmailHeaders emailJSON
          expect(@composeView.$el.find(".compose-form .bcc-input").val()).toEqual emailJSON.bccs
  
        it "updates the subject input", ->
          emailJSON = {}
          emailJSON["subject"] = @seededChance.string({length: 20})
          @composeView.loadEmailHeaders emailJSON
          subjectWithPrefixFromEmail = @composeView.subjectWithPrefixFromEmail(emailJSON)
          expect(@composeView.$el.find(".compose-form .subject-input").val()).toEqual subjectWithPrefixFromEmail
  
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

    describe "Format Email Functions", ->
      describe "#formatEmailReplyBody", ->
        beforeEach ->
          @seededChance = new Chance(1)
  
          @emailJSON = {}
          @emailJSON["date"] = "2014-09-18T21:28:48.000Z"
          @emailJSON["from_address"] =  @seededChance.email()
  
          tDate = new TDate()
          tDate.initializeWithISO8601(@emailJSON.date)
  
          @headerText = tDate.longFormDateString() + ", " + @emailJSON.from_address + " wrote:"
  
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
    
    describe "Email State", ->
      describe "#updateDraft", ->
        it "updates the email with the current email draft", ->
          @composeView.currentEmailDraft = new TuringEmailApp.Models.EmailDraft()
          spy = sinon.spy(@composeView, "updateEmail")
          @composeView.updateDraft()
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(@composeView.currentEmailDraft)
          spy.restore()
  
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
  
          @composeView.$el.find(".compose-form .to-input").val(@seededChance.email())
          @composeView.$el.find(".compose-form .cc-input").val(@seededChance.email())
          @composeView.$el.find(".compose-form .bcc-input").val(@seededChance.email())
          @composeView.$el.find(".compose-form .subject-input").val(@seededChance.string({length: 25}))
          @composeView.$el.find(".compose-form .compose-email-body").html(@seededChance.string({length: 250}))
  
          @composeView.emailInReplyToUID = chance.integer({min: 1, max: 10000})
  
          @composeView.updateEmail @email
  
        it "updates the email model with the email in reply to UID from the compose view", ->
          expect(@email.get("email_in_reply_to_uid")).toEqual @composeView.emailInReplyToUID

        it "updates the email model with the value from the tracking_enabled switch", ->
          expect(@email.get("tracking_enabled")).toEqual(
            @composeView.$el.find(".compose-form .tracking-switch").parent().parent().hasClass("switch-on")
          )
  
        it "updates the email model with the to input value from the compose form", ->
          expect(@email.get("tos")[0]).toEqual @composeView.$el.find(".compose-form .to-input").val()
  
        it "updates the email model with the cc input value from the compose form", ->
          expect(@email.get("ccs")[0]).toEqual @composeView.$el.find(".compose-form .cc-input").val()
  
        it "updates the email model with the bcc input value from the compose form", ->
          expect(@email.get("bccs")[0]).toEqual @composeView.$el.find(".compose-form .bcc-input").val()
  
        it "updates the email model with the subject input value from the compose form", ->
          expect(@email.get("subject")).toEqual @composeView.$el.find(".compose-form .subject-input").val()
  
        it "updates the email model with the html input value from the compose form", ->
          expect(@email.get("html_part")).toEqual @composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").html()

        it "updates the email model with the text input value from the compose form", ->
          expect(@email.get("text_part")).toEqual @composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").text()

      describe "#emailHasRecipients", ->
        beforeEach ->
          @email = new TuringEmailApp.Models.Email()
          @email.set("tos", [""])
          @email.set("ccs", [""])
          @email.set("bccs", [""])
        
        describe "no recipients", ->
          it "returns false", ->
            expect(@composeView.emailHasRecipients(@email)).toBeFalsy()

        describe "with a to", ->
          beforeEach ->
            @email.set("tos", ["allan@turing.com"])

          it "returns true", ->
            expect(@composeView.emailHasRecipients(@email)).toBeTruthy()

        describe "with a cc", ->
          beforeEach ->
            @email.set("ccs", ["allan@turing.com"])

          it "returns true", ->
            expect(@composeView.emailHasRecipients(@email)).toBeTruthy()

        describe "with a bcc", ->
          beforeEach ->
            @email.set("bccs", ["allan@turing.com"])

          it "returns true", ->
            expect(@composeView.emailHasRecipients(@email)).toBeTruthy()
          
    describe "Email Draft", ->
      describe "#saveDraft", ->
        beforeEach ->
          @server = sinon.fakeServer.create()

        it "updates the draft", ->
          spy = sinon.spy(@composeView, "updateDraft")
          @composeView.$el.find(".compose-form .save-button").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        describe "when the composeView is already saving the draft", ->

          it "if does not update the draft", ->
            @composeView.savingDraft = true
            spy = sinon.spy(@composeView, "updateDraft")
            @composeView.$el.find(".compose-form .save-button").click()
            expect(spy).not.toHaveBeenCalled()
            spy.restore()

        describe "when the server responds successfully", ->
          beforeEach ->
            @server.respondWith "POST", "/api/v1/email_accounts/drafts", JSON.stringify({})

          it "triggers change:draft", ->
            spy = sinon.backbone.spy(@composeView, "change:draft")
            @composeView.$el.find(".compose-form .save-button").click()
            @server.respond()
            expect(spy).toHaveBeenCalled()
            spy.restore()

          it "stops saving the draft", ->
            @composeView.$el.find(".compose-form .save-button").click()
            @server.respond()
            expect(@composeView.savingDraft).toEqual(false)

        describe "when the server responds unsuccessfully", ->
          it "stops saving the draft", ->
            @composeView.$el.find(".compose-form .save-button").click()
            @server.respond([404, {}, ""])
            expect(@composeView.savingDraft).toEqual(false)
        
    describe "Send Email", ->
      describe "#sendEmail", ->
        beforeEach ->
          @updateEmailSpy = sinon.spy(@composeView, "updateEmail")
          @updateDraftSpy = sinon.spy(@composeView, "updateDraft")
          @resetViewStub = sinon.stub(@composeView, "resetView")
          @hideStub = sinon.stub(@composeView, "hide")
          @sendUndoableEmailStub = sinon.stub(@composeView, "sendUndoableEmail")

          @composeView.$el.find(".compose-form .to-input").val("allan@turing.com")
          
        afterEach ->
          @updateEmailSpy.restore()
          @updateDraftSpy.restore()
          @resetViewStub.restore()
          @hideStub.restore()
          @sendUndoableEmailStub.restore()
          
        describe "when the current email draft is defined", ->
          beforeEach ->
            @composeView.currentEmailDraft = new TuringEmailApp.Models.EmailDraft()

          describe "when saving the draft", ->
            beforeEach ->
              @composeView.savingDraft = true
              @clock = sinon.useFakeTimers()

              @composeView.sendEmail()
              @sendEmailStub = sinon.spy(@composeView, "sendEmail")

            afterEach ->
              @clock.restore()
              @sendEmailStub.restore()
              
            it "updates the draft", ->
              expect(@updateDraftSpy).toHaveBeenCalled()
    
            it "resets the view", ->
              expect(@resetViewStub).toHaveBeenCalled()
    
            it "hides the compose modal", ->
              expect(@hideStub).toHaveBeenCalled()
  
            it "sends the email after a timeout", ->
              @clock.tick(500)
              expect(@sendEmailStub).toHaveBeenCalled()
  
          describe "when not saving the draft", ->
            beforeEach ->
              @composeView.savingDraft = false
              @server = sinon.fakeServer.create()

              @composeView.sendEmail()
  
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
            @composeView.sendEmail()

          it "updates the email", ->
            expect(@updateEmailSpy).toHaveBeenCalled()

          it "resets the view", ->
            expect(@resetViewStub).toHaveBeenCalled()

          it "hides the compose modal", ->
            expect(@hideStub).toHaveBeenCalled()
  
          it "sends the emails", ->
            expect(@sendUndoableEmailStub).toHaveBeenCalled()
      
      describe "#sendEmailDelayed", ->
        beforeEach ->
          @updateEmailSpy = sinon.spy(@composeView, "updateEmail")
          @updateDraftSpy = sinon.spy(@composeView, "updateDraft")
          @resetViewStub = sinon.stub(@composeView, "resetView")
          @hideStub = sinon.stub(@composeView, "hide")
          @sendUndoableEmailStub = sinon.stub(@composeView, "sendUndoableEmail")
          
          date = new Date()
          date.setDate(date.getDate() + 1)
          @composeView.$el.find(".compose-modal .send-later-datetimepicker").val(date.toString())

          @composeView.$el.find(".compose-form .to-input").val("allan@turing.com")

        afterEach ->
          @updateEmailSpy.restore()
          @updateDraftSpy.restore()
          @resetViewStub.restore()
          @hideStub.restore()
          @sendUndoableEmailStub.restore()

        describe "when the current email draft is defined", ->
          beforeEach ->
            @composeView.currentEmailDraft = new TuringEmailApp.Models.EmailDraft()

          describe "when saving the draft", ->
            beforeEach ->
              @composeView.savingDraft = true
              @clock = sinon.useFakeTimers()

              @composeView.sendEmailDelayed()
              @sendEmailDelayedStub = sinon.spy(@composeView, "sendEmailDelayed")

            afterEach ->
              @clock.restore()
              @sendEmailDelayedStub.restore()

            it "updates the draft", ->
              expect(@updateDraftSpy).toHaveBeenCalled()

            it "resets the view", ->
              expect(@resetViewStub).toHaveBeenCalled()

            it "hides the compose modal", ->
              expect(@hideStub).toHaveBeenCalled()

            it "sends the email after a timeout", ->
              @clock.tick(500)
              expect(@sendEmailDelayedStub).toHaveBeenCalled()

          describe "when not saving the draft", ->
            beforeEach ->
              @composeView.savingDraft = false
    
              @sendLaterStub = sinon.stub(@composeView.currentEmailDraft, "sendLater")
              @sendLaterReturn = done: sinon.stub()
              @sendLaterStub.returns(@sendLaterReturn)
              
              @composeView.sendEmailDelayed()
              
            afterEach ->
              @sendLaterStub.restore()
              
            it "sends the email later", ->
              expect(@sendLaterStub).toHaveBeenCalled()
              specCompareFunctions((=> @trigger "change:draft", this, model, @emailThreadParent), @sendLaterReturn.done.args[0][0])

        describe "when the current email draft is not defined", ->
          beforeEach ->
            @composeView.currentEmailDraft = null
            @composeView.sendEmailDelayed()

          it "updates the email", ->
            expect(@updateEmailSpy).toHaveBeenCalled()

          it "resets the view", ->
            expect(@resetViewStub).toHaveBeenCalled()

          it "hides the compose modal", ->
            expect(@hideStub).toHaveBeenCalled()
  
      describe "#sendUndoableEmail", ->
        beforeEach ->
          @email = new TuringEmailApp.Models.EmailDraft()
  
        it "shows the email sent alert", ->
          spy = sinon.spy(@composeView, "showEmailSentAlert")
          @composeView.sendUndoableEmail @email
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(@email.toJSON())
          spy.restore()
  
        it "removes the email sent alert", ->
          @clock = sinon.useFakeTimers()
          @spy = sinon.spy(@composeView, "removeEmailSentAlert")
          @composeView.sendUndoableEmail @email
  
          @clock.tick(5000)
  
          expect(@spy).toHaveBeenCalled()
          @clock.restore()
          @spy.restore()
  
        describe "when send draft is defined", ->
          beforeEach ->
            @clock = sinon.useFakeTimers()
  
            @sendDraftStub = sinon.stub(@email, "sendDraft", ->)
            @changeDraftSpy = sinon.backbone.spy(@composeView, "change:draft")
  
          afterEach ->
            @changeDraftSpy.restore()
            @sendDraftStub.restore()
            
            @clock.restore()
  
          it "should send the draft", ->
            @composeView.sendUndoableEmail @email
            @clock.tick(5000)
  
            expect(@sendDraftStub).toHaveBeenCalled()
  
          it "triggers change:draft upon being done", ->
            @composeView.sendUndoableEmail @email
            @clock.tick(5000)
            
            expect(@sendDraftStub).toHaveBeenCalled()
  
            @sendDraftStub.args[0][1]()
            expect(@changeDraftSpy).toHaveBeenCalled()
  
        describe "when send draft is not defined", ->
          beforeEach ->
            @server = sinon.fakeServer.create()
            @email = new TuringEmailApp.Models.Email()
            @clock = sinon.useFakeTimers()
  
          afterEach ->
            @clock.restore()
  
          it "should send the email", ->
            @spy = sinon.spy(@email, "sendEmail")
            @composeView.sendUndoableEmail @email
  
            @clock.tick(5000)
  
            expect(@spy).toHaveBeenCalled()
            @spy.restore()
  
          it "should should send the email after a delay if the initial sending doesn't work", ->
            @spySendEmail = sinon.spy(@email, "sendEmail")
            @spysendUndoableEmailError = sinon.spy(@composeView, "sendUndoableEmailError")
            @composeView.sendUndoableEmail @email
  
            @clock.tick(5000)
  
            expect(@spySendEmail).toHaveBeenCalled()
            @server.respond()
            expect(@spysendUndoableEmailError).toHaveBeenCalled()
            @spySendEmail.restore()
            @spysendUndoableEmailError.restore()
  
      describe "#sendUndoableEmailError", ->
  
        it "loads the email", ->
          spy = sinon.spy(@composeView, "show")
          emailJSON = {}
          @composeView.sendUndoableEmailError emailJSON
          expect(spy).toHaveBeenCalled()
          spy.restore()
  
        it "show the compose modal", ->
          spy = sinon.spy(@composeView, "show")
          @composeView.sendUndoableEmailError JSON.stringify({})
          expect(spy).toHaveBeenCalled()
          spy.restore()
  
        it "alert the user that an error occurred", ->
          @composeView.sendUndoableEmailError JSON.stringify({})
          expect(@composeView.$el).toContainHtml('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">
                                  There was an error in sending your email!</div>')
