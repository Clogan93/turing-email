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
    beforeEach ->
      @setupCreateRuleViewStub = sinon.stub(@createRuleView, "setupCreateRuleView")

      @createRuleView.render()
      
    afterEach ->
      @setupCreateRuleViewStub.restore()
      
    it "calls setupCreateRuleView", ->
      expect(@setupCreateRuleViewStub).toHaveBeenCalled()

  describe "after render", ->
    beforeEach ->
      @createRuleView.render()

    describe "#setupCreateRuleView", ->
      it "binds the submit event to create-folder-form", ->
        expect(@createRuleView.$el.find(".create-rule-form")).toHandle("submit")

    describe "#show", ->
      beforeEach ->
        @dropdownSpy = spyOnEvent(".email-rule-dropdown a", "click.bs.dropdown")
        @showSpy = sinon.spy($.prototype, "show")
        @hideSpy = sinon.spy($.prototype, "hide")

      afterEach ->
        @showSpy.restore()
        @hideSpy.restore()
        
      describe "for email_rule", ->
        beforeEach ->
          @createRuleView.show("email_rule")
        
        it "sets the folderType", ->
          expect(@createRuleView.mode).toEqual("email_rule")

        it "triggers the click.bs.dropdown event on the dropdown link", ->
          expect(@dropdownSpy).toHaveBeenTriggered()

        it "shows the create email rule destination folder input", ->
          expect(@showSpy).toHaveBeenCalled()
          expect(@hideSpy).not.toHaveBeenCalled()

      describe "for genie_rule", ->
        beforeEach ->
          @createRuleView.show("genie_rule")

        it "sets the folderType", ->
          expect(@createRuleView.mode).toEqual("genie_rule")
          
        it "triggers the click.bs.dropdown event on the dropdown link", ->
          expect(@dropdownSpy).toHaveBeenTriggered()

        it "hides the create email rule destination folder input", ->
          expect(@showSpy).not.toHaveBeenCalled()
          expect(@hideSpy).toHaveBeenCalled()

    describe "#hide", ->
      beforeEach ->
        @dropdownSpy = spyOnEvent(".email-rule-dropdown a", "click.bs.dropdown")
        
        @createRuleView.hide()

      it "triggers the click.bs.dropdown event on the dropdown link", ->
        expect(@dropdownSpy).toHaveBeenTriggered()

    describe "#resetView", ->
      beforeEach ->
        @createRuleView.$el.find(".create-rule-form .create-email-rule-to").val("This is the to input.")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-from").val("This is the cc input.")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-subject").val("This is the bcc input.")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-list").val("This is the subject input.")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-destination-folder").val("This is the destination folder input.")

        @createRuleView.resetView()

      it "clears the create rule view input fields", ->
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-to").val()).toEqual ""
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-from").val()).toEqual ""
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-subject").val()).toEqual ""
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-list").val()).toEqual ""
        expect(@createRuleView.$el.find(".create-rule-form .create-email-rule-destination-folder").val()).toEqual ""

    describe "#onSubmit", ->
      beforeEach ->
        @createRuleView.$el.find(".create-rule-form .create-email-rule-to").val("to test")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-from").val("from test")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-subject").val("subject test")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-list").val("list test")
        @createRuleView.$el.find(".create-rule-form .create-email-rule-destination-folder").val("destination")

        @server = sinon.fakeServer.create()
        @clock = sinon.useFakeTimers()

        @resetViewStub = sinon.stub(@createRuleView, "resetView")
        @hideStub = sinon.stub(@createRuleView, "hide")

        @alertToken = {}
        @showAlertStub = sinon.stub(TuringEmailApp, "showAlert", => @alertToken)
        @removeAlertStub = sinon.stub(TuringEmailApp, "removeAlert")

      afterEach ->
        @clock.restore()
        @server.restore()

        @removeAlertStub.restore()
        @showAlertStub.restore()
        @hideStub.restore()
        @resetViewStub.restore()

        @createRuleView.resetView()

      describe "when the mode is for email rules", ->
        beforeEach ->
          @createRuleView.mode = "email_rule"
          @createRuleView.onSubmit()

        it "posts the email rule creation request to the server", ->
          expect(@server.requests.length).toEqual 1
          
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/email_rules"
          
          expect(request.requestBody).toEqual("from_address=to+test&to_address=from+test&subject=subject+test&list_id=list+test&destination_folder_name=destination")

        it "shows the alert", ->
          expect(@showAlertStub).toHaveBeenCalledWith("You have successfully created an email rule!", "alert-success")

        it "removes the alert after three seconds", ->
          @clock.tick(2999)
          expect(@removeAlertStub).not.toHaveBeenCalled()
  
          @clock.tick(1);
          expect(@removeAlertStub).toHaveBeenCalledWith(@alertToken)
  
        it "resets the view", ->
          expect(@resetViewStub).toHaveBeenCalled()
  
        it "hides the view", ->
          expect(@hideStub).toHaveBeenCalled()

      describe "when the mode is for genie rules", ->
        beforeEach ->
          @createRuleView.mode = "genie_rule"
          @createRuleView.onSubmit()

        it "posts the email rule creation request to the server", ->
          expect(@server.requests.length).toEqual 1
          
          request = @server.requests[0]
          expect(request.method).toEqual "POST"
          expect(request.url).toEqual "/api/v1/genie_rules"
          
          expect(request.requestBody).toEqual("from_address=to+test&to_address=from+test&subject=subject+test&list_id=list+test")
        
        it "shows the alert", ->
          expect(@showAlertStub).toHaveBeenCalledWith("You have successfully created a brain rule!", "alert-success")
  
        it "removes the alert after three seconds", ->
          @clock.tick(2999)
          expect(@removeAlertStub).not.toHaveBeenCalled()
  
          @clock.tick(1);
          expect(@removeAlertStub).toHaveBeenCalledWith(@alertToken)
  
        it "resets the view", ->
          expect(@resetViewStub).toHaveBeenCalled()
  
        it "hides the view", ->
          expect(@hideStub).toHaveBeenCalled()