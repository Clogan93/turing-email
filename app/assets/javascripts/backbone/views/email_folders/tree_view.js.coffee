TuringEmailApp.Views.EmailFolders ||= {}

class TuringEmailApp.Views.EmailFolders.TreeView extends Backbone.View
  template: JST["backbone/templates/email_folders/tree"]

  initialize: (options) ->
    @listenTo(@collection, 'add', @render)
    @listenTo(@collection, 'reset', @render)

  render: ->
    @generate_tree()

    @$el.html(@template(nodeName: "", node: @tree))
    return this

  generate_tree: ->
    @tree = {emailFolder: null, children: {}}

    for emailFolder in @collection.toJSON()
      nameParts = emailFolder.name.split("/")
      node = @tree

      for part in nameParts
        if not node.children[part]?
          node.children[part] = {emailFolder: null, children: {}}

        node = node.children[part]

      node.emailFolder = emailFolder
