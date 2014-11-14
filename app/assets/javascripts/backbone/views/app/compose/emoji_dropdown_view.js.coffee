TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.EmojiDropdownView extends Backbone.View
  template: JST["backbone/templates/app/compose/emoji_dropdown"]

  render: ->
    return this if TestMode
    
    @$el.append(@template())

    @$el.find(".emoji-dropdown .initial-load").emoji()

    # TODO figure out how to test this, and test it.
    @emojiDropdownHeight = @$el.find(".emoji-dropdown").height()
    
    @$el.find(".emoji-dropdown").scroll (event) =>
      @$el.find(".emoji-dropdown span.subsequent-load").each (index, element) =>
        emojiScrollTop = @$el.find(".emoji-dropdown").scrollTop()
        topPosition = $(element).position()["top"]

        if topPosition > 0 and topPosition < (@emojiDropdownHeight - 10)
          $(element).emoji()
          $(element).removeClass("subsequent-load")

    return this
