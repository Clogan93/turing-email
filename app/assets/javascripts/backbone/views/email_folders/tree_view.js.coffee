TuringEmailApp.Views.EmailFolders ||= {}

class TuringEmailApp.Views.EmailFolders.TreeView extends Backbone.View
  template: JST["backbone/templates/email_folders/tree"]

  # TODO write test
  initialize: (options) ->
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

    # Set the inbox count to the number of emails in the inbox.
    inboxFolder = @collection.getEmailFolder("INBOX")

    numUnreadThreadsInInbox = inboxFolder.get("num_unread_threads")

    if numUnreadThreadsInInbox is 0
      @$el.find(".inbox_count_badge").hide()
    else
      @$el.find(".inbox_count_badge").html(numUnreadThreadsInInbox) if inboxFolder?

    select(@selectedItem(), silent: true) if @selectedItem()?
      
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

  ###############
  ### Getters ###
  ###############

  selectedItem: ->
    return @selectedEmailFolder

  ###############
  ### Actions ###
  ###############

  # TODO write test
  select: (emailFolder, options) ->
    if @selectedItem()?
      $('a[href="#email_folder/' + @selectedItem().get("label_id") + '"]').unbind "click"
      @trigger("emailFolderDeselected", this, @selectedItem())

    emailFolderID = emailFolder.get("label_id")
    
    $('a[href="#email_folder/' + emailFolderID + '"]').click (event) ->
      event.preventDefault()
      
      newURL = "#email_folder/" + emailFolderID
      if window.location.hash == newURL
        TuringEmailApp.routers.emailFoldersRouter.showFolder(emailFolderID)
      else
        TuringEmailApp.routers.emailFoldersRouter.navigate(newURL, trigger: true)

    @selectedEmailFolder = emailFolder
    
    @trigger("emailFolderSelected", this, emailFolder) if (not options?.silent?) || options.silent is false
      
  #############################
  ### TuringEmailApp Events ###
  #############################
  
  # TODO write test
  emailFolderUnreadCountChanged: (app, emailFolder) ->
    if emailFolder.get("label_id") is "INBOX"
      @$el.find(".inbox_count_badge").html(emailFolder.get("num_unread_threads"))
    else
      @$el.find(".label_count_badge").html(emailFolder.get("num_unread_threads"))
