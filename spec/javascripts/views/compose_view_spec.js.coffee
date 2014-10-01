describe "ComposeView", ->
  beforeEach ->
    specStartTuringEmailApp()

  it "has the right template", ->
    expect(TuringEmailApp.views.composeView.template).toEqual JST["backbone/templates/compose"]

  describe "#render", ->
    
    it "calls setupComposeView", ->
      spy = sinon.spy(TuringEmailApp.views.composeView, "setupComposeView")
      TuringEmailApp.views.composeView.render()
      expect(spy).toHaveBeenCalled()

  describe "#show", ->

    it "shows the compose modal", ->
      spy = sinon.spy($("#composeModal"), "modal")
      TuringEmailApp.views.composeView.show()
      expect(spy).toHaveBeenCalled()

  describe "#hide", ->

    it "hides the compose modal", ->
      spy = sinon.spy($("#composeModal"), "modal")
      TuringEmailApp.views.composeView.hide()
      expect(spy).toHaveBeenCalled()

  # describe "#updateEmail", ->
  #   beforeEach ->
  #     testEmail = new Email()

  it "clears the compose view input fields upon calling resetView", ->
    @composeView.render()

    @composeView.$el.find("#compose_form #to_input").val("This is the to input.")
    @composeView.$el.find("#compose_form #cc_input").val("This is the cc input.")
    @composeView.$el.find("#compose_form #bcc_input").val("This is the bcc input.")
    @composeView.$el.find("#compose_form #subject_input").val("This is the subject input.")
    @composeView.$el.find("#compose_form #compose_email_body").val("This is the compose email body.")
    @composeView.$el.find("#compose_form #email_in_reply_to_uid_input").val("This is the email in reply to uid input.")

    expect(@composeView.$el.find("#compose_form #to_input").val()).toEqual "This is the to input."
    expect(@composeView.$el.find("#compose_form #cc_input").val()).toEqual "This is the cc input."
    expect(@composeView.$el.find("#compose_form #bcc_input").val()).toEqual "This is the bcc input."
    expect(@composeView.$el.find("#compose_form #subject_input").val()).toEqual "This is the subject input."
    expect(@composeView.$el.find("#compose_form #compose_email_body").val()).toEqual "This is the compose email body."
    expect(@composeView.$el.find("#compose_form #email_in_reply_to_uid_input").val()).toEqual "This is the email in reply to uid input."

    @composeView.resetView()

    expect(@composeView.$el.find("#compose_form #to_input").val()).toEqual ""
    expect(@composeView.$el.find("#compose_form #cc_input").val()).toEqual ""
    expect(@composeView.$el.find("#compose_form #bcc_input").val()).toEqual ""
    expect(@composeView.$el.find("#compose_form #subject_input").val()).toEqual ""
    expect(@composeView.$el.find("#compose_form #compose_email_body").val()).toEqual ""
    expect(@composeView.$el.find("#compose_form #email_in_reply_to_uid_input").val()).toEqual ""

  it "has setupComposeView bind the submit event to #compose_form", ->
    @composeView.render()

    element = @composeView.$el.find("#compose_form")[0]
    events = $._data(element, "events")
    expect(events.hasOwnProperty('submit')).toBe true

  it "has setupComposeView bind the click event to save button", ->
    @composeView.render()

    element = @composeView.$el.find("#compose_form #save_button")[0]
    events = $._data(element, "events")
    expect(events.hasOwnProperty('click')).toBe true
