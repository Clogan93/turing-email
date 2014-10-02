describe "ComposeView", ->
  beforeEach ->
    specStartTuringEmailApp()

  it "has the right template", ->
    expect(TuringEmailApp.views.composeView.template).toEqual JST["backbone/templates/compose"]

  describe "after render", ->
    beforeEach ->
      TuringEmailApp.views.composeView.render()

    describe "#render", ->
      
      it "calls setupComposeView", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "setupComposeView")
        TuringEmailApp.views.composeView.render()
        expect(spy).toHaveBeenCalled()

    describe "#setupComposeView", ->

      it "binds the submit event to #compose_form", ->
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form")).toHandle("submit")

      it "sends an email when the #compose_form is submitted", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "sendEmail")
        TuringEmailApp.views.composeView.$el.find("#compose_form").submit()
        expect(spy).toHaveBeenCalled()

      it "binds the click event to save button", ->
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #save_button")).toHandle("click")

      describe "when the save button is clicked", ->
        beforeEach ->
          @server = sinon.fakeServer.create()

        it "updates the draft", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "updateDraft")
          TuringEmailApp.views.composeView.$el.find("#compose_form #save_button").click()
          expect(spy).toHaveBeenCalled()

        describe "when the composeView is already saving the draft", ->

          it "if does not update the draft", ->
            TuringEmailApp.views.composeView.savingDraft = true
            spy = sinon.spy(TuringEmailApp.views.composeView, "updateDraft")
            TuringEmailApp.views.composeView.$el.find("#compose_form #save_button").click()
            expect(spy).not.toHaveBeenCalled()

        describe "when the server responds successfully", ->
          beforeEach ->
            @server.respondWith "POST", "/api/v1/email_accounts/drafts", JSON.stringify({})

          it "triggers change:draft", ->
            spy = sinon.backbone.spy(TuringEmailApp.views.composeView, "change:draft")
            TuringEmailApp.views.composeView.$el.find("#compose_form #save_button").click()
            @server.respond()
            expect(spy).toHaveBeenCalled()
            spy.restore()

          it "stops saving the draft", ->
            TuringEmailApp.views.composeView.$el.find("#compose_form #save_button").click()
            @server.respond()
            expect(TuringEmailApp.views.composeView.savingDraft).toEqual(false)

        describe "when the server responds unsuccessfully", ->

          it "stops saving the draft", ->
            TuringEmailApp.views.composeView.$el.find("#compose_form #save_button").click()
            @server.respond([404, {}, ""])
            expect(TuringEmailApp.views.composeView.savingDraft).toEqual(false)

    describe "#show", ->

      it "shows the compose modal", ->
        TuringEmailApp.views.composeView.show()
        expect($("body")).toContain(".modal-backdrop.fade.in")

    describe "#hide", ->

      it "hides the compose modal", ->
        TuringEmailApp.views.composeView.hide()
        expect(TuringEmailApp.views.composeView.$el.find("#composeModal").hasClass("in")).toBeFalsy()

    describe "#resetView", ->

      it "clears the compose view input fields", ->
        TuringEmailApp.views.composeView.$el.find("#compose_form #to_input").val("This is the to input.")
        TuringEmailApp.views.composeView.$el.find("#compose_form #cc_input").val("This is the cc input.")
        TuringEmailApp.views.composeView.$el.find("#compose_form #bcc_input").val("This is the bcc input.")
        TuringEmailApp.views.composeView.$el.find("#compose_form #subject_input").val("This is the subject input.")
        TuringEmailApp.views.composeView.$el.find("#compose_form #compose_email_body").val("This is the compose email body.")

        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #to_input").val()).toEqual "This is the to input."
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #cc_input").val()).toEqual "This is the cc input."
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #bcc_input").val()).toEqual "This is the bcc input."
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #subject_input").val()).toEqual "This is the subject input."
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #compose_email_body").val()).toEqual "This is the compose email body."

        TuringEmailApp.views.composeView.resetView()

        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #to_input").val()).toEqual ""
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #cc_input").val()).toEqual ""
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #bcc_input").val()).toEqual ""
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #subject_input").val()).toEqual ""
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #compose_email_body").val()).toEqual ""

      it "removes the email sent error alert", ->
        TuringEmailApp.views.composeView.resetView()

        expect(TuringEmailApp.views.composeView.$el).not.toContainHtml('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">There was an error in sending your email!</div>')

        spy = sinon.spy(TuringEmailApp.views.composeView, "removeEmailSentAlert")
        TuringEmailApp.views.composeView.loadEmpty()
        expect(spy).toHaveBeenCalled()

      it "clears the current email draft and the email in reply to uid variables", ->
        TuringEmailApp.views.composeView.resetView()

        expect(TuringEmailApp.views.composeView.currentEmailDraft).toEqual null
        expect(TuringEmailApp.views.composeView.emailInReplyToUID).toEqual null

    describe "#loadEmpty", ->

      it "resets the view", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "resetView")
        TuringEmailApp.views.composeView.loadEmpty()
        expect(spy).toHaveBeenCalled()

      it "show the compose modal", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "show")
        TuringEmailApp.views.composeView.loadEmpty()
        expect(spy).toHaveBeenCalled()

    describe "#loadEmail", ->

      it "resets the view", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "resetView")
        TuringEmailApp.views.composeView.loadEmail JSON.stringify({})
        expect(spy).toHaveBeenCalled()

      it "loads the email headers", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailHeaders")
        emailJSON = {}
        TuringEmailApp.views.composeView.loadEmail emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

      it "loads the email body", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailBody")
        emailJSON = {}
        TuringEmailApp.views.composeView.loadEmail emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

    describe "#loadEmailDraft", ->

      it "resets the view", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "resetView")
        TuringEmailApp.views.composeView.loadEmailDraft JSON.stringify({})
        expect(spy).toHaveBeenCalled()

      it "loads the email headers", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailHeaders")
        emailJSON = {}
        TuringEmailApp.views.composeView.loadEmailDraft emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

      it "loads the email body", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailBody")
        emailJSON = {}
        TuringEmailApp.views.composeView.loadEmailDraft emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

      it "creates a new current draft object with the passed in data", ->
        emailJSON = {}
        newEmailDraft = new TuringEmailApp.Models.EmailDraft(emailJSON)
        TuringEmailApp.views.composeView.loadEmailDraft emailJSON
        expect(TuringEmailApp.views.composeView.currentEmailDraft.attributes).toEqual newEmailDraft.attributes

      it "updates the email in reply to UID", ->
        emailJSON = {}
        @seededChance = new Chance(1)
        randomID = @seededChance.integer({min: 1, max: 10000})
        TuringEmailApp.views.composeView.loadEmailDraft emailJSON, randomID
        expect(TuringEmailApp.views.composeView.emailInReplyToUID).toEqual randomID

    describe "#loadEmailAsReply", ->
      beforeEach ->
        @seededChance = new Chance(1)

      it "resets the view", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "resetView")
        TuringEmailApp.views.composeView.loadEmailAsReply JSON.stringify({})
        expect(spy).toHaveBeenCalled()

      it "loads the email body", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailBody")
        emailJSON = {}
        TuringEmailApp.views.composeView.loadEmailAsReply emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

      describe "when there is a reply to address", ->

        it "updates the to input with the reply to address", ->
          emailJSON = {}
          emailJSON["reply_to_address"] = @seededChance.email()
          TuringEmailApp.views.composeView.loadEmailAsReply emailJSON
          expect(TuringEmailApp.views.composeView.$el.find("#compose_form #to_input").val()).toEqual emailJSON.reply_to_address

      describe "when there is not a reply to address", ->

        it "updates the to input with the from address", ->
          emailJSON = {}
          emailJSON["from_address"] = @seededChance.email()
          TuringEmailApp.views.composeView.loadEmailAsReply emailJSON
          expect(TuringEmailApp.views.composeView.$el.find("#compose_form #to_input").val()).toEqual emailJSON.from_address

      it "updates the subject input", ->
        emailJSON = {}
        emailJSON["subject"] = @seededChance.string({length: 20})
        TuringEmailApp.views.composeView.loadEmailAsReply emailJSON
        subjectWithPrefixFromEmail = TuringEmailApp.views.composeView.subjectWithPrefixFromEmail(emailJSON, "Re: ")
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #subject_input").val()).toEqual subjectWithPrefixFromEmail

      it "updates the email in reply to UID", ->
        emailJSON = {}
        emailJSON.uid = chance.integer({min: 1, max: 10000})
        TuringEmailApp.views.composeView.loadEmailAsReply emailJSON
        expect(TuringEmailApp.views.composeView.emailInReplyToUID).toEqual emailJSON.uid

    describe "#loadEmailAsForward", ->
      beforeEach ->
        @seededChance = new Chance(1)

      it "resets the view", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "resetView")
        TuringEmailApp.views.composeView.loadEmailAsForward JSON.stringify({})
        expect(spy).toHaveBeenCalled()

      it "updates the subject input", ->
        emailJSON = {}
        emailJSON["subject"] = @seededChance.string({length: 20})
        TuringEmailApp.views.composeView.loadEmailAsForward emailJSON
        subjectWithPrefixFromEmail = TuringEmailApp.views.composeView.subjectWithPrefixFromEmail(emailJSON, "Fwd: ")
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #subject_input").val()).toEqual subjectWithPrefixFromEmail

      it "loads the email body", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailBody")
        emailJSON = {}
        TuringEmailApp.views.composeView.loadEmailAsForward emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

    describe "#loadEmailHeaders", ->
      beforeEach ->
        @seededChance = new Chance(1)

      it "updates the to input", ->
        emailJSON = {}
        emailJSON["tos"] = @seededChance.email()
        TuringEmailApp.views.composeView.loadEmailHeaders emailJSON
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #to_input").val()).toEqual emailJSON.tos

      it "updates the cc input", ->
        emailJSON = {}
        emailJSON["ccs"] = @seededChance.email()
        TuringEmailApp.views.composeView.loadEmailHeaders emailJSON
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #cc_input").val()).toEqual emailJSON.ccs

      it "updates the bcc input", ->
        emailJSON = {}
        emailJSON["bccs"] = @seededChance.email()
        TuringEmailApp.views.composeView.loadEmailHeaders emailJSON
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #bcc_input").val()).toEqual emailJSON.bccs

      it "updates the subject input", ->
        emailJSON = {}
        emailJSON["subject"] = @seededChance.string({length: 20})
        TuringEmailApp.views.composeView.loadEmailHeaders emailJSON
        subjectWithPrefixFromEmail = TuringEmailApp.views.composeView.subjectWithPrefixFromEmail(emailJSON)
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #subject_input").val()).toEqual subjectWithPrefixFromEmail

    describe "#loadEmailBody", ->
      beforeEach ->
        @seededChance = new Chance(1)

      it "adds blank space if the insertReplyHeader is true", ->
        # TODO fix this test.
        # emailJSON = {}
        # emailJSON["text_part"] = @seededChance.string({length: 250})
        # TuringEmailApp.views.composeView.loadEmailBody emailJSON, true
        # expect(TuringEmailApp.views.composeView.$el.find("#compose_form #compose_email_body").val()).toContain("\r\n\r\n\r\n\r\n")

      it "adds the text part to the body when it is defined", ->
        emailJSON = {}
        emailJSON["text_part"] = @seededChance.string({length: 250})
        TuringEmailApp.views.composeView.loadEmailBody emailJSON
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #compose_email_body").val()).toContain(emailJSON.text_part)

      it "adds the text part to the body when both the text part and body text are defined", ->
        emailJSON = {}
        emailJSON["text_part"] = @seededChance.string({length: 250})
        emailJSON["body_text"] = @seededChance.string({length: 250})
        TuringEmailApp.views.composeView.loadEmailBody emailJSON
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #compose_email_body").val()).toContain(emailJSON.text_part)

      it "adds the body text to the body when the text part is not defined and the body text is defined", ->
        emailJSON = {}
        emailJSON["body_text"] = @seededChance.string({length: 250})
        TuringEmailApp.views.composeView.loadEmailBody emailJSON
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #compose_email_body").val()).toContain(emailJSON.body_text)

    describe "#subjectWithPrefixFromEmail", ->
      beforeEach ->
        @seededChance = new Chance(1)

      it "returns the subject prefix if the email subject is not defined", ->
        emailJSON = {}
        subjectPrefix = "prefix"
        expect(TuringEmailApp.views.composeView.subjectWithPrefixFromEmail emailJSON, subjectPrefix).toEqual subjectPrefix

      it "strips Fwd: from the subject before prepending the subject prefix", ->
        emailJSON = {}
        subjectWithoutPrefix = @seededChance.string({length: 15})
        emailJSON["subject"] = "Fwd: " + subjectWithoutPrefix
        expect(TuringEmailApp.views.composeView.subjectWithPrefixFromEmail emailJSON).toEqual subjectWithoutPrefix

      it "strips Re: from the subject before prepending the subject prefix", ->
        emailJSON = {}
        subjectWithoutPrefix = @seededChance.string({length: 15})
        emailJSON["subject"] = "Re: " + subjectWithoutPrefix
        expect(TuringEmailApp.views.composeView.subjectWithPrefixFromEmail emailJSON).toEqual subjectWithoutPrefix

      it "prepends the subject prefix", ->
        emailJSON = {}
        subjectPrefix = "prefix"
        emailJSON["subject"] = @seededChance.string({length: 15})
        expect(TuringEmailApp.views.composeView.subjectWithPrefixFromEmail emailJSON, subjectPrefix).toEqual subjectPrefix + emailJSON["subject"]

    describe "#updateDraft", ->

      it "updates the email with the current email draft", ->
        TuringEmailApp.views.composeView.currentEmailDraft = new TuringEmailApp.Models.EmailDraft()
        spy = sinon.spy(TuringEmailApp.views.composeView, "updateEmail")
        TuringEmailApp.views.composeView.updateDraft()
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(TuringEmailApp.views.composeView.currentEmailDraft)

      it "creates a new email draft when the current email draft is not defined", ->
        TuringEmailApp.views.composeView.currentEmailDraft = null
        TuringEmailApp.views.composeView.updateDraft()
        anEmailDraft = new TuringEmailApp.Models.EmailDraft()
        TuringEmailApp.views.composeView.updateEmail(anEmailDraft)
        expect(TuringEmailApp.views.composeView.currentEmailDraft.attributes).toEqual anEmailDraft.attributes

    describe "#updateEmail", ->
      beforeEach ->
        @seededChance = new Chance(1)
        @email = new TuringEmailApp.Models.EmailDraft()

        TuringEmailApp.views.composeView.$el.find("#compose_form #to_input").val(@seededChance.email())
        TuringEmailApp.views.composeView.$el.find("#compose_form #cc_input").val(@seededChance.email())
        TuringEmailApp.views.composeView.$el.find("#compose_form #bcc_input").val(@seededChance.email())
        TuringEmailApp.views.composeView.$el.find("#compose_form #subject_input").val(@seededChance.string({length: 25}))
        TuringEmailApp.views.composeView.$el.find("#compose_form #compose_email_body").val(@seededChance.string({length: 250}))

        TuringEmailApp.views.composeView.emailInReplyToUID = chance.integer({min: 1, max: 10000})

        TuringEmailApp.views.composeView.updateEmail @email

      it "updates the email model with the email in reply to UID from the compose view", ->
        expect(@email.get("email_in_reply_to_uid")).toEqual TuringEmailApp.views.composeView.emailInReplyToUID

      it "updates the email model with the to input value from the compose form", ->
        expect(@email.get("tos")[0]).toEqual TuringEmailApp.views.composeView.$el.find("#compose_form #to_input").val()

      it "updates the email model with the cc input value from the compose form", ->
        expect(@email.get("ccs")[0]).toEqual TuringEmailApp.views.composeView.$el.find("#compose_form #cc_input").val()

      it "updates the email model with the bcc input value from the compose form", ->
        expect(@email.get("bccs")[0]).toEqual TuringEmailApp.views.composeView.$el.find("#compose_form #bcc_input").val()

      it "updates the email model with the subject input value from the compose form", ->
        expect(@email.get("subject")).toEqual TuringEmailApp.views.composeView.$el.find("#compose_form #subject_input").val()

      it "updates the email model with the email body input value from the compose form", ->
        expect(@email.get("email_body")).toEqual TuringEmailApp.views.composeView.$el.find("#compose_form #compose_email_body").val()

    describe "sendEmail", ->

      describe "when the current email draft is defined", ->
        beforeEach ->
          TuringEmailApp.views.composeView.currentEmailDraft = new TuringEmailApp.Models.EmailDraft()

          # TODO figure out how to test the sendEmail function after a timeout.

        it "updates the draft", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "updateDraft")
          TuringEmailApp.views.composeView.$el.find("#compose_form #save_button").click()
          expect(spy).toHaveBeenCalled()

        it "resets the view", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "resetView")
          TuringEmailApp.views.composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

        it "hides the compose modal", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "hide")
          TuringEmailApp.views.composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

      describe "when the current email draft is not defined", ->
        beforeEach ->
          TuringEmailApp.views.composeView.currentEmailDraft = null

        it "updates the email", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "updateEmail")
          TuringEmailApp.views.composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

        it "resets the view", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "resetView")
          TuringEmailApp.views.composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

        it "hides the compose modal", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "hide")
          TuringEmailApp.views.composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

        it "sends the email after a delay", ->
          spy = sinon.spy(TuringEmailApp.views.composeView, "sendEmailDelayed")
          TuringEmailApp.views.composeView.sendEmail()
          expect(spy).toHaveBeenCalled()

    describe "#sendEmailDelayed", ->
      beforeEach ->
        @email = new TuringEmailApp.Models.EmailDraft()

      it "shows the email sent alert", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "showEmailSentAlert")
        TuringEmailApp.views.composeView.sendEmailDelayed @email
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(@email.toJSON())

    describe "#sendEmailDelayedError", ->

      it "loads the email", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "show")
        emailJSON = {}
        TuringEmailApp.views.composeView.sendEmailDelayedError emailJSON
        expect(spy).toHaveBeenCalled()

      it "show the compose modal", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "show")
        TuringEmailApp.views.composeView.sendEmailDelayedError JSON.stringify({})
        expect(spy).toHaveBeenCalled()

      it "alert the user that an error occurred", ->
        TuringEmailApp.views.composeView.sendEmailDelayedError JSON.stringify({})
        expect(TuringEmailApp.views.composeView.$el).toContainHtml('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">
                                There was an error in sending your email!</div>')
