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

    # describe "#show", ->

    #   it "shows the compose modal", ->
    #     TuringEmailApp.views.composeView.show()
    #     expect(TuringEmailApp.views.composeView.$el.find("#composeModal").hasClass("in")).toBeTruthy()

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

    describe "#loadEmail", ->

      it "resets the view", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "resetView")
        TuringEmailApp.views.composeView.loadEmail JSON.stringify({})
        expect(spy).toHaveBeenCalled()

      it "loads the email headers", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailHeaders")
        emailJSON = JSON.stringify({})
        TuringEmailApp.views.composeView.loadEmail emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

      it "loads the email body", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "loadEmailBody")
        emailJSON = JSON.stringify({})
        TuringEmailApp.views.composeView.loadEmail emailJSON
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(emailJSON)

    describe "#sendEmailDelayedError", ->

      it "loads the email", ->
        spy = sinon.spy(TuringEmailApp.views.composeView, "show")
        emailJSON = JSON.stringify({})
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


