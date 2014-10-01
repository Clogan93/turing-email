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

      it "binds the click event to save button", ->
        expect(TuringEmailApp.views.composeView.$el.find("#compose_form #save_button")).toHandle("click")

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
        randomID = Math.random() * 1000
        TuringEmailApp.views.composeView.loadEmailDraft emailJSON, randomID
        expect(TuringEmailApp.views.composeView.emailInReplyToUID).toEqual randomID

    describe "#loadEmailAsReply", ->
      beforeEach ->
        @seededChance = new Chance(1);

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
        emailJSON.uid = chance.integer({min: 1, max: 10000});
        TuringEmailApp.views.composeView.loadEmailAsReply emailJSON
        expect(TuringEmailApp.views.composeView.emailInReplyToUID).toEqual emailJSON.uid

    describe "#loadEmailAsForward", ->
      beforeEach ->
        @seededChance = new Chance(1);

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
