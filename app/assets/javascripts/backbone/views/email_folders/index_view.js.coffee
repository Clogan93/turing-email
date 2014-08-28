TuringEmailApp.Views.EmailFolders ||= {}

class TuringEmailApp.Views.EmailFolders.IndexView extends Backbone.View
  template: JST["backbone/templates/email_folders/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (emailFolder) =>
    view = new TuringEmailApp.Views.EmailFolders.EmailFolderView({model : emailFolder})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(emailFolders: @collection.toJSON() ))
    @addAll()

    return this
