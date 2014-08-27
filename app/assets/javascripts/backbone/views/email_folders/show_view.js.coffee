TuringEmailApp.Views.EmailFolders ||= {}

class TuringEmailApp.Views.EmailFolders.ShowView extends Backbone.View
  template: JST["backbone/templates/email_folders/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
