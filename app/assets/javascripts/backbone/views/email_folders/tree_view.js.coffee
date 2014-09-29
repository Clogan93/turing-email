TuringEmailApp.Views.EmailFolders ||= {}

class TuringEmailApp.Views.EmailFolders.TreeView extends Backbone.View
  template: JST["backbone/templates/email_folders/tree"]

  initialize: (options) ->
    @listenTo(@collection, "add", @render)
    @listenTo(@collection, "remove", @render)
    @listenTo(@collection, "reset", @render)
    @listenTo(@collection, "destroy", @remove)

    @listenTo(options.app, "change:currentEmailFolder", @currentEmailFolderChanged)

  render: ->
    @generateTree()

    @$el.html(@template(nodeName: "", node: @tree))

    @$el.find(".bullet_span").click ->
      $(this).parent().children("ul").children("li").toggle()

    return this

  generateTree: ->
    @tree = {emailFolder: null, children: {}}

    for emailFolder in @collection.toJSON()
      nameParts = emailFolder.name.split("/")
      node = @tree

      for part in nameParts
        if not node.children[part]?
          node.children[part] = {emailFolder: null, children: {}}

        node = node.children[part]

      node.emailFolder = emailFolder

  #############################
  ### TuringEmailApp Events ###
  #############################
  
  currentEmailFolderChanged: (app, emailFolderID) ->
    if @currentEmailFolderID?
      $('a[href="#email_folder/' + @currentEmailFolderID + '"]').unbind "click"
      
    $('a[href="#email_folder/' + emailFolderID + '"]').click (event) ->
      event.preventDefault()
      TuringEmailApp.collections.emailThreads.fetch(reset: true)
    
    @currentEmailFolderID = emailFolderID
 