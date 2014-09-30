describe "EmailThreadView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailThreadFixtures = fixture.load("email_thread.fixture.json")
    @validEmailThreadFixture = emailThreadFixtures[0]["valid"]
    
    @emailThread = new TuringEmailApp.Models.EmailThread(undefined, emailThreadUID: @validEmailThreadFixture["uid"])
    @emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: @emailThread
    )

    @server = sinon.fakeServer.create()

    @server.respondWith "GET", @emailThread.url, JSON.stringify(@validEmailThreadFixture)

  afterEach ->
    @server.restore()

  it "has the right template", ->
    expect(@emailThreadView.template).toEqual JST["backbone/templates/email_threads/email_thread"]

  describe "after fetch", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    describe "#render", ->

      it "should have the root element be a div", ->
        expect(@emailThreadView.el.nodeName).toEqual "DIV"

      it "should render the attributes of all the email threads", ->
        #Set up lists
        fromNames = []
        textParts = []

        #Collect Attributes from the rendered DOM.
        @emailThreadView.$el.find('.email_information .col-md-3').each ->
          fromNames.push $(this).text().trim()
        @emailThreadView.$el.find('.email_body .col-md-11').each ->
          textParts.push $(this).text().trim()

        #Run expectations
        for email, index in @emailThread.get("emails")
          expect(fromNames[index]).toEqual email.from_name
          expect(textParts[index]).toEqual email.text_part

      # it "should render the subject attribute", ->
      #   expect(@emailThreadView.$el.find('#email_subject').text().trim()).toEqual @emailThread.get("emails")[0].subject

    describe "#setupButtons", ->
      
      it "should handle clicks", ->
        expect(@emailThreadView.$el.find('#email_back_button')).toHandle("click")
        expect(@emailThreadView.$el.find(".email_reply_button")).toHandle("click")
        expect(@emailThreadView.$el.find(".email_forward_button")).toHandle("click")
        expect(@emailThreadView.$el.find("i.fa-archive").parent()).toHandle("click")
        expect(@emailThreadView.$el.find("i.fa-trash-o").parent()).toHandle("click")

      describe "when email_reply_button is clicked", ->
        it "triggers replyClicked", ->
          spy = sinon.backbone.spy(@emailThreadView, "replyClicked")
          @emailThreadView.$el.find(".email_reply_button").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when email_forward_button is clicked", ->
        it "triggers forwardClicked", ->
          spy = sinon.backbone.spy(@emailThreadView, "forwardClicked")
          @emailThreadView.$el.find(".email_forward_button").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when the archive button is clicked", ->
        it "triggers archiveClicked", ->
          spy = sinon.backbone.spy(@emailThreadView, "archiveClicked")
          @emailThreadView.$el.find("i.fa-archive").parent().click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when trash button is clicked", ->
        it "triggers trashClicked", ->
          spy = sinon.backbone.spy(@emailThreadView, "trashClicked")
          @emailThreadView.$el.find("i.fa-trash-o").parent().click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when isSplitPaneMode() is off", ->

        it "should have email_back_button handle clicks", ->
          expect(@emailThreadView.$el.find('#email_back_button')).toHandle("click")

        describe "when email_back_button is clicked", ->
          it "triggers goBackClicked", ->
            spy = sinon.backbone.spy(@emailThreadView, "goBackClicked")
            @emailThreadView.$el.find("#email_back_button").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

    describe "#setupEmailExpandAndCollapse", ->

      it "should have .email handle clicks", ->
        expect(@emailThreadView.$el.find('.email')).toHandle("click")

      describe "when a .email is clicked", ->
        
        it "should call show on the email body", ->
          aDotEmailElement = @emailThreadView.$el.find('.email').first()
          spy = sinon.spy(aDotEmailElement.find(".email_body"), "show")
          aDotEmailElement.click()
          expect(spy).toHaveBeenCalled()
