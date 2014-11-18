describe "ComposeButtonView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @composeButtonView = new TuringEmailApp.Views.App.ComposeButtonView()

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@composeButtonView.template).toEqual JST["backbone/templates/app/sidebar/compose_button"]

  describe "#render", ->
    beforeEach ->
      @composeButtonView.render()      

    it "binds a click to the quick compose links", ->
      expect(@composeButtonView.$el.find(".quick-compose-item")).toHandle("click")

    describe "when a quick compose item is clicked", ->

      # TODO fix this test.
      # it "adds text to the body", ->
      #   firstQuickCompose = @composeButtonView.$el.find(".quick-compose-item").first()
      #   quickComposeText = firstQuickCompose.text().replace("Quick Compose: ", "")
      #   firstQuickCompose.click()
      #   expect($(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable")).toContainText(quickComposeText)

      it "adds text to the subject-input", ->
        firstQuickCompose = @composeButtonView.$el.find(".quick-compose-item").first()
        quickComposeText = firstQuickCompose.text().replace("Quick Compose: ", "")
        firstQuickCompose.click()
        expect($(".compose-modal .subject-input").val()).toEqual(quickComposeText)
