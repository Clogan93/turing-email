TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.EmojiDropdownView extends Backbone.View
  template: JST["backbone/templates/app/compose/emoji_dropdown"]

  render: ->
    @$el.append(@template())

    @$el.find(".emoji-dropdown .initial-load").emoji()

    # TODO figure out how to test this, and test it.
    @$el.find(".emoji-dropdown").scroll (event) =>
      @$el.find(".emoji-dropdown span.subsequent-load").each ->
        emojiScrollTop = $(".dropdown-menu.emoji-dropdown").scrollTop()
        topPosition = $(@).position()["top"]
        if topPosition > 0 and topPosition < 220
          $(@).emoji()
          $(@).removeClass("subsequent-load")

    return this
