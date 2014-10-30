TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.AlertView extends Backbone.View
  template: JST["backbone/templates/app/alert"]

  initialize: (options) ->
    @classType = options.classType
    @text = options.text
    @token = _.uniqueId()

  render: ->
    @$el.html(@template({'text' : @text}))
    @$el.addClass("text-center")
    @$el.addClass("alert")
    @$el.addClass(@classType)
    @$el.attr("role", "alert")
    @$el.attr("style", "z-index: 2000; margin-bottom: 0px; position: absolute; width: 100%;")

    token = @token

    @$el.find(".dismiss-alert-link").click(=>
      TuringEmailApp.removeAlert(token)
    )

    return this
