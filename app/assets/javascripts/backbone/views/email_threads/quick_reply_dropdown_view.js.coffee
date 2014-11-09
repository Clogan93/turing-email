TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.QuickReplyView extends Backbone.View
  template: JST["backbone/templates/email_threads/quick_reply_dropdown"]

  initialize: (options) ->
    @emailThreadView = options.emailThreadView

  render: ->
    @$el.after(@template())

    @$el.parent().find(".single-click-communication-link").click (event) =>
      event.preventDefault()
      @emailThreadView.trigger("replyClicked", @emailThreadView)
      $(".compose-modal .note-editable").prepend($(event.target).text())
      $(".compose-modal .send-button").click()

    return this
