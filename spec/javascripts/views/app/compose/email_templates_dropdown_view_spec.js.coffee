describe "EmailTemplatesDropdownView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailTemplatesAttributes = FactoryGirl.create("EmailTemplatesCollection")
    emailTemplates = new TuringEmailApp.Collections.EmailTemplatesCollection()
    emailTemplates.set(emailTemplatesAttributes.toJSON())

    @emailTemplatesDropdownView = new TuringEmailApp.Views.App.EmailTemplatesDropdownView(
      collection: emailTemplates
      el: TuringEmailApp.views.composeView.$el.find(".send-later-button")
      composeView: TuringEmailApp.views.composeView
    )

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@emailTemplatesDropdownView.template).toEqual JST["backbone/templates/app/compose/email_templates_dropdown"]

  describe "#render", ->
    beforeEach ->
      @emailTemplatesDropdownView.render()
