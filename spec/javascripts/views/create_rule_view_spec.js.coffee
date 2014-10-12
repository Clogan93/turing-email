describe "CreateRuleView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @createRuleDiv = $("<div class='create_rule_view'></div>").appendTo("body")
    @createRuleView = new TuringEmailApp.Views.App.CreateRuleView(
      app: TuringEmailApp
      el: $(".create_rule_view")
    )

  afterEach ->
    @createRuleDiv.remove()
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@createRuleView.template).toEqual JST["backbone/templates/app/create_rule"]

  describe "#render", ->

    it "calls setupCreateRuleView", ->
      spy = sinon.spy(@createRuleView, "setupCreateRuleView")
      @createRuleView.render()
      expect(spy).toHaveBeenCalled()

  describe "after render", ->
    beforeEach ->
      @createRuleView.render()

    describe "#setupCreateRuleView", ->
      it "binds the submit event to create-folder-form", ->
        expect(@createRuleView.$el.find(".create-rule-form")).toHandle("submit")

      describe "when the create rule form is submitted", ->
        beforeEach ->
          @server = sinon.fakeServer.create()

          @createRuleView.$el.find(".create-rule-form .create-email-rule-to").val("to test")
          @createRuleView.$el.find(".create-rule-form .create-email-rule-from").val("from test")
          @createRuleView.$el.find(".create-rule-form .create-email-rule-subject").val("subject test")
          @createRuleView.$el.find(".create-rule-form .create-email-rule-list").val("list test")
          @createRuleView.$el.find(".create-rule-form .create-email-rule-destination-folder").val("destination folder test")

        afterEach ->
          @createRuleView.resetView()

        describe "when the mode is for email rules", ->
          beforeEach ->
            @createRuleView.show("email_rule")

          it "posts the email rule creation request to the server", ->
            @createRuleView.$el.find(".create-rule-form").submit()

            expect(@server.requests.length).toEqual 1
            request = @server.requests[0]
            expect(request.method).toEqual "POST"
            expect(request.requestBody).toContain "to+test"
            expect(request.requestBody).toContain "from+test"
            expect(request.requestBody).toContain "subject+test"
            expect(request.requestBody).toContain "list+test"
            expect(request.requestBody).toContain "destination+folder+test"
            expect(request.url).toEqual "/api/v1/email_rules"

          it "shows the alert", ->
            spy = sinon.spy(TuringEmailApp, "showAlert")
            @createRuleView.$el.find(".create-rule-form").submit()
            expect(spy).toHaveBeenCalled()
            spy.restore()

        describe "when the mode is for genie rules", ->
          beforeEach ->
            @createRuleView.show("genie_rule")

          it "posts the email rule creation request to the server", ->
            @createRuleView.$el.find(".create-rule-form").submit()

            expect(@server.requests.length).toEqual 1
            request = @server.requests[0]
            expect(request.method).toEqual "POST"
            expect(request.requestBody).toContain "to+test"
            expect(request.requestBody).toContain "from+test"
            expect(request.requestBody).toContain "subject+test"
            expect(request.requestBody).toContain "list+test"
            expect(request.requestBody).not.toContain "destination+folder+test"
            expect(request.url).toEqual "/api/v1/genie_rules"

          it "shows the alert", ->
            spy = sinon.spy(TuringEmailApp, "showAlert")
            @createRuleView.$el.find(".create-rule-form").submit()
            expect(spy).toHaveBeenCalled()
            spy.restore()

        it "removes the alert after three seconds", ->
          clock = sinon.useFakeTimers()

          spy = sinon.spy(TuringEmailApp, "removeAlert")
          @createRuleView.$el.find(".create-rule-form").submit()

          clock.tick(2999)
          expect(spy).not.toHaveBeenCalled()

          clock.tick(3000)
          expect(spy).toHaveBeenCalled()
          
          spy.restore()
          clock.restore()

        it "resets the create rule view", ->
          spy = sinon.spy(@createRuleView, "resetView")
          @createRuleView.$el.find(".create-rule-form").submit()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "hides the create rule view", ->
          spy = sinon.spy(@createRuleView, "hide")
          @createRuleView.$el.find(".create-rule-form").submit()
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#show", ->
      describe "for email_rule", ->
          
        it "sets the folderType", ->
          @createRuleView.show("email_rule")
          expect(@createRuleView.mode).toEqual("email_rule")

        it "triggers the click.bs.dropdown event on the dropdown link", ->
          spy = spyOnEvent('#email-rule-dropdown a', 'click.bs.dropdown')
          @createRuleView.show("email_rule")
          expect('click.bs.dropdown').toHaveBeenTriggeredOn('#email-rule-dropdown a')

          expect(spy).toHaveBeenTriggered()

        it "shows the create email rule destination folder input", ->
          spy = sinon.spy($.prototype, "show")
          @createRuleView.show("email_rule")
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "for genie_rule", ->
        beforeEach ->
          @createRuleView.show("genie_rule")

        it "sets the folderType", ->
          expect(@createRuleView.mode).toEqual("genie_rule")

        it "triggers the click.bs.dropdown event on the dropdown link", ->
          spy = spyOnEvent('#email-rule-dropdown a', 'click.bs.dropdown')
          @createRuleView.show("genie_rule")
          expect('click.bs.dropdown').toHaveBeenTriggeredOn('#email-rule-dropdown a')

          expect(spy).toHaveBeenTriggered()

        it "shows the create email rule destination folder input", ->
          spy = sinon.spy($.prototype, "hide")
          @createRuleView.show("genie_rule")
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#hide", ->

      it "hides the create folder modal", ->
        @createRuleView.hide()
        expect(@createRuleView.$el.find(".create-folder-modal").hasClass("in")).toBeFalsy()

    describe "#resetView", ->

      it "clears the create rule view input fields", ->
        @createRuleView.$el.find(".create-rule-form .create-email-rule-to").val("This is the to input.")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-from").val("This is the cc input.")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-subject").val("This is the bcc input.")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-list").val("This is the subject input.")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-destination-folder").val("This is the destination folder input.")

        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-to").val()).toEqual "This is the to input."
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-from").val()).toEqual "This is the cc input."
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-subject").val()).toEqual "This is the bcc input."
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-list").val()).toEqual "This is the subject input."
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-destination-folder").val()).toEqual "This is the destination folder input."

        @createRuleView.resetView()

        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-to").val()).toEqual ""
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-from").val()).toEqual ""
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-subject").val()).toEqual ""
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-list").val()).toEqual ""
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-destination-folder").val()).toEqual ""
