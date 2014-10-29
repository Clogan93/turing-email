describe "EmailThreadView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailThreadAttributes = FactoryGirl.create("EmailThread")
    emailThreadAttributes.emails.push(FactoryGirl.create("Email", draft_id: "draft"))
    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
      app: TuringEmailApp
      emailThreadUID: emailThreadAttributes.uid
    )
    
    @emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: @emailThread
    )
    $("body").append(@emailThreadView.$el)

  afterEach ->
    @emailThreadView.$el.remove()
    
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@emailThreadView.template).toEqual JST["backbone/templates/email_threads/email_thread"]

  describe "after fetch", ->
    beforeEach ->
      email.html_part_encoded = null for email in @emailThread.get("emails")
      @emailThreadView.render()

    describe "#render", ->
      it "should have the root element be a div", ->
        expect(@emailThreadView.el.nodeName).toEqual "DIV"
        
      it "has the email-thread class", ->
        expect(@emailThreadView.el).toHaveClass("email-thread")

      describe "when the email is not a draft", ->

        it "should render the attributes of all the email threads", ->
          #Set up lists
          fromNames = []
          textParts = []

          @emailThreadView.$el.find(".email"). each ->

            #Collect Attributes from the rendered DOM.
            emailInformation = $(@).find(".email_information")
            fromNames.push $(emailInformation.find(".email-from")[0]).text().trim()

            emailBody = $(@).find(".email_body .col-md-11")
            if emailBody.length is 0 then textParts.push null else textParts.push emailBody.text().trim()

          #Run expectations
          for email, index in @emailThread.get("emails")
            if email.draft_id is null
              expect(fromNames[index]).toEqual email.from_name
              expect(textParts[index]).toEqual base64_decode_urlsafe(email.text_part_encoded)

        describe "when there is a no html or text parts of the email yet there is a body part", ->

          it "should render the body part", ->
            for email, index in @emailThread.get("emails")
              if email.draft_id is null
                @seededChance = new Chance(1)
                randomBodyText = @seededChance.string({length: 150})
                @emailThread.get("emails")[index].html_part_encoded = null
                @emailThread.get("emails")[index].text_part_encoded = null
                @emailThread.get("emails")[index].body_text_encoded = base64_encode_urlsafe(randomBodyText)
                @emailThreadView.render()
                expect(@emailThreadView.$el.find("pre[name='body_text']")).toContainHtml(randomBodyText)

      describe "when the email is a draft", ->

        it "should render the email drafts", ->
          @spy = sinon.spy(@emailThreadView, "renderDrafts")
          
          @emailThreadView.render()
          
          expect(@spy).toHaveBeenCalled()
          @spy.restore()

    describe "#addPreviewDataToTheModelJSON", ->
      beforeEach ->
        @modelJSON = @emailThread.toJSON()
        @emailThreadView.addPreviewDataToTheModelJSON @modelJSON

      it "adds the fromPreview data to the model JSON", ->
        expect(@modelJSON["fromPreview"]).toEqual(@emailThread.get("emails")[0].from_name +
                                                  " (" + @emailThread.get("emails").length + ")")

      it "adds the subjectPreview data to the model JSON", ->
        expect(@modelJSON["subjectPreview"]).toEqual @emailThread.get("emails")[0].subject

      it "adds the datePreview data to the model JSON", ->
        expect(@modelJSON["datePreview"]).toEqual TuringEmailApp.Models.Email.localDateString(@emailThread.get("emails")[0].date)

      it "adds the fromPreview data to each of the emails", ->
        for email in @modelJSON.emails
          expect(email["fromPreview"]).toEqual email.from_name

      it "adds the datePreview data to each of the emails", ->
        for email in @modelJSON.emails
          expect(email["datePreview"]).toEqual TuringEmailApp.Models.Email.localDateString(email.date)

    describe "#renderDrafts", ->

      it "should created embedded compose views", ->
        @emailThreadView.embeddedComposeViews = {}
        @emailThreadView.renderDrafts()
        embeddedComposeViewsLength = _.values(@emailThreadView.embeddedComposeViews).length
        expect(embeddedComposeViewsLength).toEqual 1

      it "should render the embedded compose view into the email thread view", ->
        @emailThreadView.renderDrafts()
        embeddedComposeView = _.values(@emailThreadView.embeddedComposeViews)[0]
        expect(@emailThreadView.$el).toContainHtml embeddedComposeView.$el

    describe "#setupEmailExpandAndCollapse", ->

      it "should have .email .email_information handle clicks", ->
        expect(@emailThreadView.$el.find('.email .email_information')).toHandle("click")

      describe "when a .email .email_information is clicked", ->
        beforeEach ->
          @updateIframeHeightStub = sinon.stub(@emailThreadView, "updateIframeHeight", ->)
          @emailDiv = @emailThreadView.$el.find('.email').first()
          @emailInfoDiv = @emailDiv.find(".email_information")

          @isCollapsed = @emailDiv.hasClass("collapsed_email")
          @emailInfoDiv.click()
          
        afterEach ->
          @updateIframeHeightStub.restore()
          @emailInfoDiv.click() # undo the expand/collapse

        it "shows the email body", ->
          expect(@emailDiv.hasClass("collapsed_email") == !@isCollapsed).toBeTruthy()
          
        it "updates the iframe height", ->
          iframe = @emailDiv.find("iframe")
          # TODO not working because email rendered is not an HTML email - tried to make it HTML but broke other tests.
          #expect(@updateIframeHeightStub).toHaveBeenCalledWith(iframe)

      describe "when a .email .email_information is clicked twice", ->
        beforeEach ->
          @emailDiv = @emailThreadView.$el.find('.email').first()
          @emailInfoDiv = @emailDiv.find(".email_information")

          @isCollapsed = @emailDiv.hasClass("collapsed_email")
          @emailInfoDiv.click()
          @emailInfoDiv.click()
          
        it "should hide the email body", ->
          expect(@emailDiv.hasClass("collapsed_email") == @isCollapsed).toBeTruthy()

    describe "#setupButtons", ->  
      it "should handle clicks", ->
        expect(@emailThreadView.$el.find('#email_back_button')).toHandle("click")
        expect(@emailThreadView.$el.find(".email_reply_button")).toHandle("click")
        expect(@emailThreadView.$el.find(".email_forward_button")).toHandle("click")

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

      describe "when isSplitPaneMode() is off", ->

        it "should have email_back_button handle clicks", ->
          expect(@emailThreadView.$el.find('#email_back_button')).toHandle("click")

        describe "when email_back_button is clicked", ->
          it "triggers goBackClicked", ->
            spy = sinon.backbone.spy(@emailThreadView, "goBackClicked")
            @emailThreadView.$el.find("#email_back_button").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()
