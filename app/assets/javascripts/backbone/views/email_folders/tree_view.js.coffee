TuringEmailApp.Views.EmailFolders ||= {}

class TuringEmailApp.Views.EmailFolders.TreeView extends Backbone.View
  template: JST["backbone/templates/email_folders/tree"]

  # TODO write test
  initialize: (options) ->
    @listenTo(options.app, "change:currentEmailFolder", @currentEmailFolderChanged)
    @listenTo(options.app, "change:emailFolderUnreadCount", @emailFolderUnreadCountChanged)
    
    @listenTo(@collection, "add", @render)
    @listenTo(@collection, "remove", @render)
    @listenTo(@collection, "reset", @render)
    @listenTo(@collection, "destroy", @remove)

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

  # TODO write test
  currentEmailFolderChanged: (app, emailFolderID) ->
    if @currentEmailFolderID?
      $('a[href="#email_folder/' + @currentEmailFolderID + '"]').unbind "click"

    $('a[href="#email_folder/' + emailFolderID + '"]').click (event) ->
      event.preventDefault()
      @routers.emailFoldersRouter.navigate("#email_folder/" + emailFolderID, trigger: true)

    @currentEmailFolderID = emailFolderID
  
  # TODO write test
  emailFolderUnreadCountChanged: (app, emailFolder) ->
    if emailFolder.get("label_id") is "INBOX"
      $(".inbox_count_badge").html(emailFolder.get("num_unread_threads"))
    else
      @$el.find(".label_count_badge").html(emailFolder.get("num_unread_threads"))
