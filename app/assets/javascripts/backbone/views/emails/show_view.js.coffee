TuringEmailApp.Views.Emails ||= {}

class TuringEmailApp.Views.Emails.ShowView extends Backbone.View
  template: JST["backbone/templates/emails/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
