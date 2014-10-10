class TuringEmailApp.Views.Main extends Backbone.View
  template: JST["backbone/templates/main"]

  initialize: (options) ->
    @app = options.app
    
    $(window).resize((event) => @onWindowResize(event))

    @toolbarView = new TuringEmailApp.Views.ToolbarView(
      app: @app
    )
    
  render: ->
    @$el.html(@template())
    
    @primaryPaneDiv = @$el.find(".primary_pane")
    
    @sidebarView = new @app.Views.App.SidebarView(
      el: @$el.find("[name=sidebar]")
    )
    @sidebarView.render()

    @footerView = new TuringEmailApp.Views.App.FooterView(
      el: @$el.find("#footer")
    )
    @footerView.render()

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

    @resize()

  createEmailThreadsListView: (emailThreads) ->
    @emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView(
      collection: emailThreads
    )
    
    return @emailThreadsListView

  ########################
  ### Resize Functions ###
  ########################
    
  onWindowResize: (event) ->
    @resize()
    
  resize: ->
    @resizeSidebar()
    @resizePrimaryPane()
    @resizeSplitPane()
    
  resizeSidebar: ->
    return if not @sidebarView?

    height = $(window).height() - @sidebarView.$el.offset().top - 6
    height -= @footerView.$el.outerHeight(true) if @footerView?
    @sidebarView.$el.height(height)
    
  resizePrimaryPane: ->
    return if not @primaryPaneDiv?
    
    height = $(window).height() - @primaryPaneDiv.offset().top - 6
    height -= @footerView.$el.outerHeight(true) if @footerView?
    @primaryPaneDiv.height(height)
    
  resizeSplitPane: ->
    splitPaneDiv = @$el.find(".split_pane")
    return if splitPaneDiv.length is 0

    height = $(window).height() - splitPaneDiv.offset().top - 6
    height -= @footerView.$el.outerHeight(true) if @footerView?
    height = 1 if height <= 0
    
    splitPaneDiv.height(height)

  ######################
  ### View Functions ###
  ######################
    
  showEmails: (isSplitPaneMode) ->
    return false if not @primaryPaneDiv?

    @primaryPaneDiv.html("")

    emailThreadsListViewDiv = $('<div class="mail-box email_threads_list_view" style="border: none; margin: 0px;">
                                   <table class="table table-hover table-mail">
                                     <tbody class="email_threads_list_view_tbody"></tbody>
                                   </table>
                                 </div>')

    @primaryPaneDiv.append(@toolbarView.$el)
    @toolbarView.render()

    if isSplitPaneMode
      splitPane = $("<div />", {class: "split_pane"}).appendTo(@primaryPaneDiv)

      emailThreadsListViewDiv.addClass("ui-layout-center")
      splitPane.append(emailThreadsListViewDiv)
      
      emailThreadViewDiv = $("<div />", {class: "email_thread_view"}).appendTo(splitPane)
      emailThreadViewDiv.addClass("ui-layout-south")

      @resizeSplitPane()
      
      @splitPaneLayout = splitPane.layout({
        applyDefaultStyles: true,
        resizable: true,
        livePaneResizing: true,
        showDebugMessages: true

        south__size: if @splitPaneLayout? then @splitPaneLayout.state.south.size else 0.5
      });
    else
      @primaryPaneDiv.append(emailThreadsListViewDiv)
    
    @emailThreadsListView.$el = @$el.find(".email_threads_list_view_tbody")
    @emailThreadsListView.render()
    
    return true
    
  showSettings: ->
    return false if not @primaryPaneDiv?
    
    settingsView = new TuringEmailApp.Views.SettingsView(
      model: @app.models.userSettings
    )
    settingsView.render()
    
    @primaryPaneDiv.html(settingsView.$el)
    
    return settingsView

  showAnalytics: ->
    return false if not @primaryPaneDiv?

    analyticsView = new TuringEmailApp.Views.AnalyticsView()
    analyticsView.render()

    @primaryPaneDiv.html(analyticsView.$el)
    
    return analyticsView

  showReport: (divReportsID, ReportModel, ReportView) ->
    return false if not @primaryPaneDiv?

    reportModel = new ReportModel()
    
    if divReportsID
      reportView = new ReportView(
        model: reportModel
        el: $("#" + divReportsID)
      )
    else
      reportView = new ReportView(
        model: reportModel
      )

      @primaryPaneDiv.html(reportView.$el)

    reportModel.fetch()
    
    return reportView

  showEmailThread: (emailThread, isSplitPaneMode) ->
    return false if not @primaryPaneDiv?

    emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: emailThread
    )
    
    if isSplitPaneMode
      emailThreadViewDiv = @$el.find(".email_thread_view")

      if emailThreadViewDiv.length is 0
        @showEmails(isSplitPaneMode)
        emailThreadViewDiv = @$el.find(".email_thread_view")
    else
      emailThreadViewDiv = @primaryPaneDiv

    emailThreadViewDiv.html("")
    emailThreadViewDiv.append(emailThreadView.$el)
    
    emailThreadView.render()
  
    return emailThreadView
