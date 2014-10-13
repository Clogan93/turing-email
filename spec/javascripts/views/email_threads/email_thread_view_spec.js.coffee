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

    specStopTuringEmailApp()

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
        @emailThreadView.$el.find(".email_information").each ->
          fromNames.push $($(this).find(".col-md-2")[0]).text().trim()
          
        @emailThreadView.$el.find(".email_body .col-md-11").each ->
          textParts.push $(this).text().trim()

        #Run expectations
        for email, index in @emailThread.get("emails")
          expect(fromNames[index]).toEqual email.from_name
          expect(textParts[index]).toEqual email.text_part

      # it "should render the subject attribute", ->
      #   expect(@emailThreadView.$el.find('#email_subject').text().trim()).toEqual @emailThread.get("emails")[0].subject

      describe " when there is a no html or text parts of the email yet there is a body part", ->

        it "should render the body part", ->
          @seededChance = new Chance(1)
          randomBodyText = @seededChance.string({length: 150})
          @emailThread.get("emails")[0].html_part = null
          @emailThread.get("emails")[0].text_part = null
          @emailThread.get("emails")[0].body_text = randomBodyText
          @emailThreadView.render()
          expect(@emailThreadView.$el.find("pre[name='body_text']")).toContainHtml(randomBodyText)

    describe "#setupEmailExpandAndCollapse", ->

      it "should have .email .email_information handle clicks", ->
        expect(@emailThreadView.$el.find('.email .email_information')).toHandle("click")

      describe "when a .email .email_information is clicked", ->
        afterEach ->
          @emailThreadView.$el.find('.email').first().find(".email_body").css("display", "none")

        it "should show the email body", ->
          @emailThreadView.$el.find('.email .email_information').first().click()
          expect(@emailThreadView.$el.find('.email').first().find(".email_body").css("display")).toEqual "block"

      describe "when a .email .email_information is clicked twice", ->
        it "should hide the email body", ->
          @emailThreadView.$el.find('.email .email_information').first().click()
          @emailThreadView.$el.find('.email .email_information').first().click()
          expect(@emailThreadView.$el.find('.email').last().find(".email_body").css("display")).toEqual "none"

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
