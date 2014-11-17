describe "EmailTagDropdownView", ->
  beforeEach ->    
    specStartTuringEmailApp()
    @emailTagDropdownView = new TuringEmailApp.Views.App.EmailTagDropdownView(
      composeView: TuringEmailApp.views.composeView
    )

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@emailTagDropdownView.template).toEqual JST["backbone/templates/app/compose/email_tag_dropdown"]

  describe "#render", ->
    beforeEach ->
      @emailTagDropdownView.render()      

    it "binds a click to the email tag item links", ->
      expect(@emailTagDropdownView.$el.find(".email-tag-item")).toHandle("click")

    describe "when an email tag item link is clicked", ->

      it "adds a meta tag to the body", ->
        firstEmailTag = @emailTagDropdownView.$el.find(".email-tag-item").first()
        firstEmailTagText = firstEmailTag.text().toLowerCase()
        firstEmailTag.click()
        expect($(".compose-modal .note-editable")).toContainHtml("<meta name='email-type-tag' content='" + firstEmailTagText + "'>")

      it "show the success alert", ->
        spy = sinon.spy(TuringEmailApp, "showAlert")
        @emailTagDropdownView.$el.find(".email-tag-item").first().click()
        expect(spy).toHaveBeenCalled()
        spy.restore()
