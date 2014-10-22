describe "EmbeddedComposeView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailThreadFixtures = fixture.load("email_thread.fixture.json")
    @validEmailThreadFixture = emailThreadFixtures[0]["valid"]
    
    @emailThread = new TuringEmailApp.Models.EmailThread(undefined, emailThreadUID: @validEmailThreadFixture["uid"])
    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @emailThread.url, JSON.stringify(@validEmailThreadFixture)

    @embeddedComposeView = new TuringEmailApp.Views.App.EmbeddedComposeView(app: TuringEmailApp)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@embeddedComposeView.template).toEqual JST["backbone/templates/app/compose/embedded_compose_view"]

  describe "after render", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

      @draftEmail = null
      for email in @emailThread.get("emails")
        if email.draft_id?
          @draftEmail = email
          break

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
