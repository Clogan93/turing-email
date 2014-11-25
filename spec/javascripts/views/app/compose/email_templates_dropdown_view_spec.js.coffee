describe "EmailTemplatesDropdownView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailTemplates = new TuringEmailApp.Collections.EmailTemplatesCollection()
    emailTemplates.add(FactoryGirl.createLists("EmailTemplate", FactoryGirl.SMALL_LIST_SIZE))

    @emailTemplatesDropdownView = new TuringEmailApp.Views.App.EmailTemplatesDropdownView(
      collection: emailTemplates
      el: TuringEmailApp.views.composeView.$el.find(".send-later-button")
      composeView: TuringEmailApp.views.composeView
    )

    @server = sinon.fakeServer.create()

  afterEach ->
    specStopTuringEmailApp()
    @server.restore()

  it "has the right template", ->
    expect(@emailTemplatesDropdownView.template).toEqual JST["backbone/templates/app/compose/email_templates_dropdown"]

  describe "#render", ->
    beforeEach ->
      @emailTemplatesDropdownView.render()

    it "renders the email template dropdown", ->
      expect(TuringEmailApp.views.composeView.$el).toContain(".email-templates-dropdown-div")

    it "renders the email template links", ->
      for emailTemplate in @emailTemplatesDropdownView.collection.models
        expect(@emailTemplatesDropdownView.$el.parent()).toContainText(emailTemplate.get("name"))

    it "renders the email template create link", ->
      expect(@emailTemplatesDropdownView.$el.parent()).toContain(".create-email-template")

    it "renders the email template delete link", ->
      expect(@emailTemplatesDropdownView.$el.parent()).toContain(".delete-email-template")

    it "renders the email template update link", ->
      expect(@emailTemplatesDropdownView.$el.parent()).toContain(".update-email-template")

    describe "#cleanUpEmailTemplateUI", ->
      
      it "removes the email templates dropdown and the dialogs", ->
        expect(TuringEmailApp.views.composeView.$el).toContain(".email-templates")
        expect($("body")).toContain(".create-email-templates-dialog-form")
        expect($("body")).toContain(".delete-email-templates-dialog-form")
        expect($("body")).toContain(".update-email-templates-dialog-form")

        @emailTemplatesDropdownView.cleanUpEmailTemplateUI()

        expect(TuringEmailApp.views.composeView.$el).not.toContain(".email-templates")
        expect($("body")).not.toContain(".create-email-templates-dialog-form")
        expect($("body")).not.toContain(".delete-email-templates-dialog-form")
        expect($("body")).not.toContain(".update-email-templates-dialog-form")

    describe "#createEmailTemplate", ->
      it "posts", ->
        @emailTemplatesDropdownView.createEmailTemplate()

        expect(@server.requests.length).toEqual 1
        request = @server.requests[0]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "/api/v1/email_templates"

      # describe "upon success", ->
      #   beforeEach ->
      #     @createEmailTemplateStub = sinon.stub(@emailTemplatesDropdownView, "createEmailTemplate", ->)

      #   afterEach ->
      #     @createEmailTemplateStub.restore()

      #   it "show the alert", ->
      #     spy = sinon.spy(TuringEmailApp, "showAlert")
      #     @emailTemplatesDropdownView.createEmailTemplate()
      #     @createEmailTemplateStub.args[0][0].success(@emailTemplatesDropdownView.collections, {})
      #     expect(spy).toHaveBeenCalled()
      #     spy.restore()

    describe "#deleteEmailTemplate", ->

      it "DELETE", ->
        @emailTemplatesDropdownView.deleteEmailTemplate()
        
        expect(@server.requests.length).toEqual 2
        
        request = @server.requests[0]
        
        expect(request.method).toEqual "DELETE"
        expect(request.url).toEqual "/api/v1/email_templates/41"

      it "show the alert", ->
        spy = sinon.spy(TuringEmailApp, "showAlert")
        @emailTemplatesDropdownView.deleteEmailTemplate()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "#updateEmailTemplate", ->

      it "patches", ->
        @emailTemplatesDropdownView.updateEmailTemplate()
        
        expect(@server.requests.length).toEqual 5
        
        request = @server.requests[0]
        
        expect(request.method).toEqual "PATCH"
        expect(request.url).toContainText "/api/v1/email_templates"
