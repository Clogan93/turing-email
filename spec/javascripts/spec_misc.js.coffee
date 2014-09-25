window.specStartTuringEmailApp = ->
  TuringEmailApp.models = {}
  TuringEmailApp.views = {}
  TuringEmailApp.collections = {}
  TuringEmailApp.routers = {}

  TuringEmailApp.models.user = new TuringEmailApp.Models.User()
  TuringEmailApp.models.userSettings = new TuringEmailApp.Models.UserSettings()

  TuringEmailApp.collections.emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
  TuringEmailApp.routers.emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()
  TuringEmailApp.views.emailFoldersTreeView = new TuringEmailApp.Views.EmailFolders.TreeView(
    el: $("#email_folders")
    collection: TuringEmailApp.collections.emailFolders
  )
  TuringEmailApp.views.toolbarView = new TuringEmailApp.Views.ToolbarView(
    el: $("#email-folder-mail-header")
    collection: TuringEmailApp.collections.emailFolders
  )

  TuringEmailApp.views.composeView = new TuringEmailApp.Views.ComposeView(
    el: $("#modals")
  )

  TuringEmailApp.routers.emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()

  #Routers
  TuringEmailApp.routers.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
  TuringEmailApp.routers.analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()
  TuringEmailApp.routers.settingsRouter = new TuringEmailApp.Routers.SettingsRouter()
  TuringEmailApp.routers.searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()

  Backbone.history.start(silent: true)

window.validateAttributes = (objectJSON, expectedAttributes) ->
  keys = (key for key in Object.keys(objectJSON))
  keys.sort()

  expectedAttributes = expectedAttributes.slice().sort()
  
  expect(keys).toEqual expectedAttributes

window.validateUserAttributes = (userJSON) ->
  expectedAttributes = ["email"]
  validateAttributes(userJSON, expectedAttributes)
  
window.validateUserSettingsAttributes = (userSettingsJSON) ->
  expectedAttributes = ["genie_enabled", "split_pane_mode"]
  validateAttributes(userSettingsJSON, expectedAttributes)
  
window.validateEmailFolderAttributes = (emailFolderJSON) ->
  expectedAttributes = ["label_id", "name",
                         "message_list_visibility", "label_list_visibility",
                         "label_type",
                         "num_threads", "num_unread_threads"]
  validateAttributes(emailFolderJSON, expectedAttributes)


window.validateEmailThreadAttributes = (emailThreadJSON) ->
  expectedAttributes = ["uid", "emails"]
  validateAttributes(emailThreadJSON, expectedAttributes)
  
window.validateEmailAttributes = (emailJSON) ->
  expectedAttributes = ["auto_filed",
                        "uid", "draft_id", "message_id", "list_id",
                        "seen", "snippet", "date",
                        "from_name", "from_address",
                        "sender_name", "sender_address",
                        "reply_to_name", "reply_to_address",
                        "tos", "ccs", "bccs",
                        "subject",
                        "html_part", "text_part", "body_text"]
  validateAttributes(emailJSON, expectedAttributes)
