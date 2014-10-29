class TuringEmailApp.Views.Main extends Backbone.View
  template: JST["backbone/templates/main"]

  initialize: (options) ->
    @app = options.app
    
    $(window).resize((event) => @onWindowResize(event))

    @toolbarView = new TuringEmailApp.Views.ToolbarView(
      app: @app
    )

    @miniatureToolbarView = new TuringEmailApp.Views.MiniatureToolbarView(
      app: @app
    )

  render: ->
    @$el.html(@template())
    
    @primaryPaneDiv = @$el.find(".primary_pane")
    
    @sidebarView = new @app.Views.App.SidebarView(
      el: @$el.find("[name=sidebar]")
    )
    @sidebarView.render()

    @composeView = new TuringEmailApp.Views.App.ComposeView(
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
    @resizePrimarySplitPane()
    @resizeAppsSplitPane()
    @resizeEmailThreadsListView()
    
  resizeSidebar: ->
    return if not @sidebarView?

    height = $(window).height() - @sidebarView.$el.offset().top - 6
    @sidebarView.$el.height(height)
    
  resizePrimaryPane: ->
    return if not @primaryPaneDiv?
    
    height = $(window).height() - @primaryPaneDiv.offset().top - 6
    @primaryPaneDiv.height(height)
    
  resizePrimarySplitPane: ->
    primarySplitPaneDiv = @$el.find(".primary_split_pane")
    return if primarySplitPaneDiv.length is 0

    height = $(window).height() - primarySplitPaneDiv.offset().top - 6
    height = 1 if height <= 0
    
    primarySplitPaneDiv.height(height)

  resizeAppsSplitPane: ->
    appsSplitPaneDiv = @$el.find(".apps_split_pane")
    return if appsSplitPaneDiv.length is 0

    height = $(window).height() - appsSplitPaneDiv.offset().top - 20
    height = 1 if height <= 0

    appsSplitPaneDiv.height(height)
    
  resizeEmailThreadsListView: ->
    return if not @emailThreadsListView?
    
    subject = @emailThreadsListView.$el.find(".mail-subject.contain-subject")
    return if subject.length is 0
    
    subjectOffset = subject.first().offset()
    subjectLeftPosition = Math.ceil(subjectOffset.left)
    datePreviewWidth = @emailThreadsListView.$el.find(".text-right.mail-date").first().outerWidth(true)
    newWidth = $(window).width() - subjectLeftPosition - datePreviewWidth - 2
    @emailThreadsListView.$el.find(".mail-subject.contain-subject").css("max-width", newWidth)

  ######################
  ### View Functions ###
  ######################
    
  showEmails: (isSplitPaneMode) ->
    return false if not @primaryPaneDiv?

    @primaryPaneDiv.html("")

    emailThreadsListViewDiv = $('<div class="mail-box email-threads-list-view">
                                   <table class="table table-hover table-mail">
                                     <tbody class="email-threads-list-view-tbody"></tbody>
                                   </table>
                                 </div>')

    @primaryPaneDiv.append(@toolbarView.$el)
    @toolbarView.render()

    if isSplitPaneMode
      primarySplitPane = $("<div />", {class: "primary_split_pane"}).appendTo(@primaryPaneDiv)

      if @emailThreadsListView.collection.length is 0
        emptyFolderMessageDiv = $("<div />", {class: "ui-layout-center"}).appendTo(primarySplitPane)
      else
        emailThreadsListViewDiv.addClass("ui-layout-center")
        primarySplitPane.append(emailThreadsListViewDiv)
      
      emailThreadViewDiv = $("<div class='email_thread_view'><div class='email-thread-view-default-text'>No conversations selected</div></div>").appendTo(primarySplitPane)
      emailThreadViewDiv.addClass("ui-layout-south")

      @resizePrimarySplitPane()
      
      @splitPaneLayout = primarySplitPane.layout({
        applyDefaultStyles: true,
        resizable: true,
        closable: false,
        livePaneResizing: true,
        showDebugMessages: true,

        south__size: if @splitPaneLayout? then @splitPaneLayout.state.south.size else 0.5,
        south__onresize: => @resizeAppsSplitPane()
      });
    else
      if @emailThreadsListView.collection.length is 0
        emptyFolderMessageDiv = @primaryPaneDiv
      else
        @primaryPaneDiv.append(emailThreadsListViewDiv)

    if @emailThreadsListView.collection.length is 0
      if @app.selectedEmailFolderID() is "INBOX"
        emptyFolderMessageDiv.append("<div class='empty-text'>Congratulations on reaching inbox zero!</div>")
      else
        emptyFolderMessageDiv.append("<div class='empty-text'>There are no conversations with this label.</div>")
      @toolbarView.refreshToolbarButtonView.show()
    else
      @emailThreadsListView.$el = @$el.find(".email-threads-list-view-tbody")
      @emailThreadsListView.render()
      @resizeEmailThreadsListView()
      @toolbarView.refreshToolbarButtonView.hide()

    return true

  showAppsLibrary: ->
    return false if not @primaryPaneDiv?

    apps = new TuringEmailApp.Collections.AppsCollection()
    apps.fetch()
    appsLibraryView = new TuringEmailApp.Views.AppsLibrary.AppsLibraryView(collection: apps)
    appsLibraryView.render()
    
    @primaryPaneDiv.html("")
    @primaryPaneDiv.append(appsLibraryView.$el)
    
    return appsLibraryView
    
  showSettings: ->
    return false if not @primaryPaneDiv?
    
    settingsView = new TuringEmailApp.Views.SettingsView(
      model: @app.models.userSettings
      emailRules: @app.collections.emailRules
      brainRules: @app.collections.brainRules
    )
    settingsView.render()

    @primaryPaneDiv.html("")
    @primaryPaneDiv.append(@miniatureToolbarView.$el)
    @miniatureToolbarView.render()
    @primaryPaneDiv.append(settingsView.$el)

    return settingsView

  showAnalytics: ->
    return false if not @primaryPaneDiv?

    analyticsView = new TuringEmailApp.Views.AnalyticsView()
    analyticsView.render()

    @primaryPaneDiv.html("")
    @primaryPaneDiv.append(analyticsView.$el)
    
    return analyticsView

  showReport: (ReportModel, ReportView) ->
    return false if not @primaryPaneDiv?

    reportModel = new ReportModel()
    reportView = new ReportView(
      model: reportModel
    )

    @primaryPaneDiv.html("")
    @primaryPaneDiv.append(reportView.$el)

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

    if @app.models.userSettings?.get("installed_apps")?.length > 0
      appsSplitPane = $("<div />", {class: "apps_split_pane"}).appendTo(emailThreadViewDiv)
      
      emailThreadView.$el.addClass("ui-layout-center")
      appsSplitPane.append(emailThreadView.$el)
      emailThreadView.render()
  
      appsDiv = $("<div />").appendTo(appsSplitPane)
      appsDiv.addClass("ui-layout-east")

      if emailThread?
        for installedAppJSON in @app.models.userSettings.get("installed_apps")
          appIframe = $("<iframe></iframe>").appendTo(appsDiv)
          appIframe.css("width", "160px")
          appIframe.css("border", "solid 1px black")
          installedApp = TuringEmailApp.Models.InstalledApps.InstalledApp.CreateFromJSON(installedAppJSON)
          installedApp.run(appIframe, emailThread)
      
      @resizeAppsSplitPane()
  
      appsSplitPane.layout({
        applyDefaultStyles: true,
        resizable: false,
        closable: false,
        livePaneResizing: true,
        showDebugMessages: true,
  
        east__size: 200
      });
    else
      emailThreadViewDiv.off("resize")
      emailThreadViewDiv.html(emailThreadView.$el)
      emailThreadView.render()

    return emailThreadView
