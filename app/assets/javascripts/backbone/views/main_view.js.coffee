class TuringEmailApp.Views.Main extends Backbone.View
  template: JST["backbone/templates/main"]

  initialize: (options) ->
    @app = options.app
  
  render: ->
    @$el.html(@template())
    
    @sidebarView = new @app.Views.App.SidebarView(
      el: @$el.find("#sidebar")
    )
    @sidebarView.render()

    @footerView = new TuringEmailApp.Views.App.FooterView(
      el: @$el.find("#footer")
    )
    @footerView.render()

    @toolbarView = new TuringEmailApp.Views.ToolbarView(
      app: @app
    )
    @toolbarView.render()

    @composeView = new TuringEmailApp.Views.ComposeView(
      app: @app
      el: @$el.find("#compose_view")
    )
    @composeView.render()
    
  createEmailThreadsListView: (emailThreads) ->
    @emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView(
      collection: emailThreads
    )
    
    return @emailThreadsListView
    
  showEmails: ->
    $("#primaryPane").html("")
    $("#primaryPane").append(@toolbarView.$el)
    @toolbarView.render()
    
    $("#primaryPane").append('<div class="mail-box" name="email_threads_list_view">
                             <table class="table table-hover table-mail">
                               <tbody id="email_table_body"></tbody>
                             </table>
                           </div>')
    
    @emailThreadsListView.$el = $("#email_table_body")
    @emailThreadsListView.render()
    
  showSettings: ->
    settingsView = new TuringEmailApp.Views.SettingsView(
      model: TuringEmailApp.models.userSettings
      el: $("#primaryPane")
    )

    settingsView.render()
    
    return settingsView

  showAnalytics: ->
    analyticsView = new TuringEmailApp.Views.AnalyticsView(
        el: $("#primaryPane")
      )

    analyticsView.render()
    
    return analyticsView

  showReport: (divReportsID = "primaryPane", ReportModel, ReportView) ->
    reportModel = new ReportModel()
    reportView = new ReportView(
      model: reportModel
      el: $("#" + divReportsID)
    )

    reportModel.fetch()
    
    return reportView
