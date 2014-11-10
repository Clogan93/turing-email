describe "EmojiDropdownView", ->
  beforeEach ->
    @emojiDropdownView = new TuringEmailApp.Views.App.EmojiDropdownView(
    )

  it "has the right template", ->
    expect(@emojiDropdownView.template).toEqual JST["backbone/templates/app/compose/emoji_dropdown"]

  describe "#render", ->

    it "calls emoji on the emoji dropdown", ->
      @emojiStub = sinon.stub($.fn, "emoji")
      @emojiDropdownView.render()
      expect(@emojiStub).toHaveBeenCalled()
      @emojiStub.restore()
