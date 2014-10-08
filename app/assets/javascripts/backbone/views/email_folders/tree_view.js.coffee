TuringEmailApp.Views.EmailFolders ||= {}

class TuringEmailApp.Views.EmailFolders.TreeView extends Backbone.View
  template: JST["backbone/templates/email_folders/tree"]

  # TODO write test
  initialize: (options) ->
    @app = options.app
    
    @listenTo(options.app, "change:emailFolderUnreadCount", @emailFolderUnreadCountChanged)
    
    @listenTo(@collection, "add", @render)
    @listenTo(@collection, "remove", @render)
    @listenTo(@collection, "reset", @render)
    @listenTo(@collection, "destroy", @remove)

  render: ->
    @generateTree()

    systemBadges =
      inbox: @collection.getEmailFolder("INBOX")?.badgeString()
      draft: @collection.getEmailFolder("DRAFT")?.badgeString()
    
    @$el.html(@template(nodeName: "", node: @tree, systemBadges: systemBadges))

    @setupNodes()

    select(@selectedItem(), silent: true) if @selectedItem()?
      
    return this

  generateTree: ->
    @tree = {emailFolder: null, children: {}}

    for emailFolder in @collection.models
      emailFolderJSON = emailFolder.toJSON()
      emailFolderJSON.badgeString = emailFolder.badgeString()
      
      nameParts = emailFolderJSON.name.split("/")
      node = @tree

      for part in nameParts
        if not node.children[part]?
          node.children[part] = {emailFolder: null, children: {}}

        node = node.children[part]

      node.emailFolder = emailFolderJSON

  #############
  ### Setup ###
  #############
    
  setupNodes: ->
    @$el.find(".bullet_span").click (event) =>
      $(event.target).parent().children("ul").children("li").toggle()
      
    @$el.find('a').click (event) =>
      event.preventDefault()

      emailFolderID = $(event.currentTarget).attr("href")
      emailFolder = @collection.getEmailFolder(emailFolderID)
      @select(emailFolder, force: true)

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
    return if @selectedItem() is emailFolder && options?.force != true

    if @selectedItem()?
      @trigger("emailFolderDeselected", this, @selectedItem())

    @selectedEmailFolder = emailFolder

    @trigger("emailFolderSelected", this, emailFolder) if (not options?.silent?) || options.silent is false

  updateBadgeCount: (emailFolder) ->
    emailFolderID = emailFolder.get("label_id")

    if emailFolderID is "INBOX"
      @$el.find('.inbox_count_badge').html(emailFolder.badgeString())
    else
      @$el.find('a[href="' + emailFolderID + '"]>.badge').html(emailFolder.badgeString())
      
  #############################
  ### TuringEmailApp Events ###
  #############################
  
  # TODO write test
  emailFolderUnreadCountChanged: (app, emailFolder) ->
    @updateBadgeCount(emailFolder)
