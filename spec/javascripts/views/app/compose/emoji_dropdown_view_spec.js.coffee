describe "EmojiDropdownView", ->
  beforeEach ->
    window.TestMode = false
    
    @emojiDropdownView = new TuringEmailApp.Views.App.EmojiDropdownView()
    
  afterEach ->
    window.TestMode = true

  it "has the right template", ->
    expect(@emojiDropdownView.template).toEqual JST["backbone/templates/app/compose/emoji_dropdown"]

  describe "#render", ->

    it "calls emoji on the emoji dropdown", ->
      @emojiStub = sinon.stub($.fn, "emoji")
      @emojiDropdownView.render()
      expect(@emojiStub).toHaveBeenCalled()
      @emojiStub.restore()
