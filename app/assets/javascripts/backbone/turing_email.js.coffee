#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

window.TuringEmailApp = new(Backbone.View.extend({
  Models: {}
  Views: {}
  Collections: {}
  Routers: {}

  initialize: ->
    #Collections
    #this.Collections.inbox = new Inbox()

    #View
    #this.Views.emailFolderView = new InboxView(collection: this.Collections.inbox)

  start: ->
    @user = new TuringEmailApp.Models.User()
    @user.fetch()

    @emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter({emailFolders: []})
    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
    @emailFoldersTreeView = new TuringEmailApp.Views.EmailFolders.TreeView({
      el :$("#email_folders") ,
      collection: @emailFolders
    })

    @emailFolders.fetch({
      success: (collection, response, options) ->
        TuringEmailApp.emailFoldersTreeView.render()

        $(".bullet_span").click ->
          $(this).parent().children("ul").children("li").toggle()
          
      error: (collection, response, options) ->
        alert("AHHH")
    })
    
#    $("#app").html this.Views.emailFolderView.el
#    this.Collections.inbox.fetch success: (collection, response, options) ->
#
#      TuringEmailApp.Views.emailFolderView.render()
#
#      TuringEmailApp.bind_collapsed_email_thread_functionality()
#
#      # Set the inbox count to the number of emails in the inbox.
#      $("#inbox_count_badge").html collection.unreadCount()  
    
    #window.emailsRouter = new TuringEmailApp.Routers.EmailsRouter({emails: []})

    Backbone.history.start()
}))({el: document.body})