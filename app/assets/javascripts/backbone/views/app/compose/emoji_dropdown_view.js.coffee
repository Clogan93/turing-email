TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.EmojiDropdownView extends Backbone.View
  template: JST["backbone/templates/app/compose/emoji_dropdown"]

  render: ->
    @$el.append(@template())

    @$el.find(".emoji-dropdown").emoji()

    return this
