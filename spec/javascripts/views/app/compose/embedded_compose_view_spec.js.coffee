describe "EmbeddedComposeView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailThreadAttributes = FactoryGirl.create("EmailThread")
    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
      app: TuringEmailApp
      emailThreadUID: emailThreadAttributes.uid
    )

    @embeddedComposeView = new TuringEmailApp.Views.App.EmbeddedComposeView(app: TuringEmailApp)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@embeddedComposeView.template).toEqual JST["backbone/templates/app/compose/embedded_compose_view"]

  describe "after render", ->
    beforeEach ->

      @draftEmail = @emailThread.get("emails")[0]
      @draftEmail.draft_id = 1

      @embeddedComposeView.email = @draftEmail
      @embeddedComposeView.emailThread = @emailThread
      @embeddedComposeView.render()

    describe "#render", ->
      
      it "calls setupComposeView", ->
        spy = sinon.spy(@embeddedComposeView, "setupComposeView")
        @embeddedComposeView.render()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      it "sets the current email draft", ->
        currentEmailDraft = new TuringEmailApp.Models.EmailDraft(@draftEmail)
        expect(@embeddedComposeView.currentEmailDraft.attributes).toEqual currentEmailDraft.attributes

    describe "#hide", ->

      it "hides the embedded compose view", ->
        hideSpy = sinon.spy($.prototype, "hide")

        @embeddedComposeView.hide()

        expect(hideSpy).toHaveBeenCalled()
        hideSpy.restore()
