specStartedHistory = false

window.specStartTuringEmailApp = ->
  TuringEmailApp.models = {}
  TuringEmailApp.views = {}
  TuringEmailApp.collections = {}
  TuringEmailApp.routers = {}

  TuringEmailApp.views.toolbarView = new TuringEmailApp.Views.ToolbarView(
    app: TuringEmailApp
  )

  TuringEmailApp.models.user = new TuringEmailApp.Models.User()
  TuringEmailApp.models.userSettings = new TuringEmailApp.Models.UserSettings()
  
  TuringEmailApp.collections.emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
  TuringEmailApp.views.emailFoldersTreeView = new TuringEmailApp.Views.EmailFolders.TreeView(
    app: TuringEmailApp
    el: $("#email_folders")
    collection: TuringEmailApp.collections.emailFolders
  )

  TuringEmailApp.views.composeView = new TuringEmailApp.Views.ComposeView(
    app: TuringEmailApp
  )
  TuringEmailApp.listenTo(TuringEmailApp.views.composeView, "change:draft", TuringEmailApp.draftChanged)

  TuringEmailApp.collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()
  TuringEmailApp.views.emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView(
    el: $("#email_table_body")
    collection: TuringEmailApp.collections.emailThreads
  )

  TuringEmailApp.routers.emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()
  TuringEmailApp.routers.emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()
  TuringEmailApp.routers.analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()
  TuringEmailApp.routers.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
  TuringEmailApp.routers.settingsRouter = new TuringEmailApp.Routers.SettingsRouter()
  TuringEmailApp.routers.searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()

  if not specStartedHistory
    Backbone.history.start(silent: true)
    specStartedHistory = true

window.specPrepareEmailFoldersFetch = (emailFolders, server) ->
  emailFoldersFixtures = fixture.load("email_folders.fixture.json")
  validEmailFoldersFixture = emailFoldersFixtures[0]["valid"]
  
  emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection() if not emailFolders?
  
  server = sinon.fakeServer.create() if not server?
  server.respondWith "GET", emailFolders.url, JSON.stringify(validEmailFoldersFixture)
  
  return [server, validEmailFoldersFixture]

window.specPrepareEmailThreadsFetch = (emailThreads, server) ->
  emailThreadsFixtures = fixture.load("email_threads.fixture.json");
  validEmailThreadsFixture = emailThreadsFixtures[0]["valid"]

  emailThreads = new TuringEmailApp.Collections.EmailFoldersCollection() if not emailThreads?

  server = sinon.fakeServer.create() if not server?
  server.respondWith "GET", emailThreads.url, JSON.stringify(validEmailThreadsFixture)

  return [server, validEmailThreadsFixture]
  
window.specPrepareEmailThreadFetch = (server) ->
  emailThreadFixtures = fixture.load("email_thread.fixture.json")
  validEmailThreadFixture = emailThreadFixtures[0]["valid"]
  
  emailThread = new TuringEmailApp.Models.EmailThread(undefined, emailThreadUID: validEmailThreadFixture["uid"])
  
  server = sinon.fakeServer.create() if not server?
  server.respondWith "GET", emailThread.url, JSON.stringify(validEmailThreadFixture)

  return [server, emailThread, validEmailThreadFixture]
  
window.specCreateEmailThreadsListView = (server) ->
  emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()

  listViewDiv = $("<div />", {id: "email_table_body"}).appendTo("body")
  emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView(
    el: listViewDiv
    collection: emailThreads
  )

  [server, validEmailThreadsFixture] = specPrepareEmailThreadsFetch(emailThreads, server)
  emailThreads.fetch()
  server.respond()
  
  return [listViewDiv, emailThreadsListView, emailThreads, server, validEmailThreadsFixture]
  
window.validateAttributes = (objectJSON, expectedAttributes) ->
  keys = (key for key in _.keys(objectJSON))
  keys.sort()

  expectedAttributes = expectedAttributes.slice().sort()
  
  expect(keys).toEqual expectedAttributes

window.validateUserAttributes = (userJSON) ->
  expectedAttributes = ["email"]
  validateAttributes(userJSON, expectedAttributes)
  
window.validateUserSettingsAttributes = (userSettingsJSON) ->
  expectedAttributes = ["id", "genie_enabled", "split_pane_mode"]
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
