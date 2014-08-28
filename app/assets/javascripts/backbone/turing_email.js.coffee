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

  start: ->
    @user = new TuringEmailApp.Models.User()
    @user.fetch()

    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
    @emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()
    @emailFoldersTreeView = new TuringEmailApp.Views.EmailFolders.TreeView({
      el: $("#email_folders"),
      collection: @emailFolders
    })

    @emailFolders.fetch({
      success: (collection, response, options) ->
        TuringEmailApp.emailFoldersTreeView.render()

        $(".bullet_span").click ->
          $(this).parent().children("ul").children("li").toggle()
          
      error: (collection, response, options) ->
        alert("AHHH @emailFolders.fetch")
    })

    @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()
    @emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()
    @emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView({
        el: $("#app")
        collection: @emailThreads
    })

    @emailThreads.fetch({
      success: (collection, response, options) ->
        TuringEmailApp.emailThreadsListView.render()

        # Set the inbox count to the number of emails in the inbox.
        $("#inbox_count_badge").html collection.unreadCount()

      error: (collection, response, options) ->
        alert("AHHH @emailThreads.fetch")
    })
    
    #window.emailsRouter = new TuringEmailApp.Routers.EmailsRouter({emails: []})

    Backbone.history.start()
}))({el: document.body})