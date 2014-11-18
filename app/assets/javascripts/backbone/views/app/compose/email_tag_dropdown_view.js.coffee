TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.EmailTagDropdownView extends Backbone.View
  template: JST["backbone/templates/app/compose/email_tag_dropdown"]

  initialize: (options) ->
    @composeView = options.composeView

  render: ->
    @$el.append(@template())

    @$el.find(".email-tag-item").click (event) =>
      @composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").append("<meta name='email-type-tag' content='" + $(event.target).text().toLowerCase() + "'>")
      token = TuringEmailApp.showAlert("Email tag successfully inserted!", "alert-success")

      setTimeout (=>
        TuringEmailApp.removeAlert(token)
      ), 3000

    return this
