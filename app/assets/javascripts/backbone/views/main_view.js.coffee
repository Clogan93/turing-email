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

    @createFolderView = new TuringEmailApp.Views.EmailFolders.CreateFolderView(
      app: @app
      el: @$el.find(".create_folder_view")
    )
    @createFolderView.render()

  createEmailThreadsListView: (emailThreads) ->
    @emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView(
      collection: emailThreads
    )
    
    return @emailThreadsListView
    
  showEmails: ->
    $("#primary_pane").html("")
    $("#primary_pane").append(@toolbarView.$el)
    @toolbarView.render()
    
    $("#primary_pane").append('<div class="mail-box" name="email_threads_list_view">
                             <table class="table table-hover table-mail">
                               <tbody id="email_table_body"></tbody>
                             </table>
                           </div>')
    
    @emailThreadsListView.$el = $("#email_table_body")
    @emailThreadsListView.render()
    
  showSettings: ->
    settingsView = new TuringEmailApp.Views.SettingsView(
      model: TuringEmailApp.models.userSettings
      el: $("#primary_pane")
    )

    settingsView.render()
    
    return settingsView

  showAnalytics: ->
    analyticsView = new TuringEmailApp.Views.AnalyticsView(
        el: $("#primary_pane")
      )

    analyticsView.render()
    
    return analyticsView

  showReport: (divReportsID = "primary_pane", ReportModel, ReportView) ->
    reportModel = new ReportModel()
    reportView = new ReportView(
      model: reportModel
      el: $("#" + divReportsID)
    )

    reportModel.fetch()
    
    return reportView

  showEmailThread: (emailThread, isSplitPaneMode) ->
    if isSplitPaneMode
      @$el.find("#preview_panel").show()
      emailThreadViewSelector = "#preview_content"
    else
      @$el.find("#preview_panel").hide()
      emailThreadViewSelector = "#primary_pane"

    emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: emailThread
      el: $(emailThreadViewSelector)
    )
    emailThreadView.render()
  
    return emailThreadView
