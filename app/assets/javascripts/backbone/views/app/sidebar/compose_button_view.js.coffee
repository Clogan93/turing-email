TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.ComposeButtonView extends Backbone.View
  template: JST["backbone/templates/app/sidebar/compose_button"]

  render: ->
    @$el.prepend(@template())

    @$el.find(".quick-compose-item").click (event) =>
      @$el.find(".compose-button").click()
      quickComposeText = $(event.target).text().replace("Quick Compose: ", "")
      $(".compose-modal .note-editable").prepend(quickComposeText)
      $(".compose-modal .subject-input").val(quickComposeText)
      $(".compose-modal .to-input").focus()

    return this
