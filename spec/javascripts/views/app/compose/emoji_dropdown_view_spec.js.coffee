describe "EmojiDropdownView", ->
  beforeEach ->
    window.TestEmoji = true
    
    @emojiDropdownView = new TuringEmailApp.Views.App.EmojiDropdownView()
    
  afterEach ->
    window.TestEmoji = false

  it "has the right template", ->
    expect(@emojiDropdownView.template).toEqual JST["backbone/templates/app/compose/emoji_dropdown"]

  describe "#render", ->

    it "calls emoji on the emoji dropdown", ->
      @emojiStub = sinon.stub($.fn, "emoji")
      @emojiDropdownView.render()
      expect(@emojiStub).toHaveBeenCalled()
      @emojiStub.restore()
