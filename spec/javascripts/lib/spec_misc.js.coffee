specStartedHistory = false

oldPrettyPrinterFormat = jasmine.PrettyPrinter::format
jasmine.PrettyPrinter::format = (value) ->
  self = this
  if value instanceof Backbone.Model
    @emitObject value.attributes
  else if value instanceof Backbone.Collection
    value.each (model) ->
      self.emitScalar model.cid
      return

  else
    oldPrettyPrinterFormat.apply this, arguments
  return

window.specStopTuringEmailApp = ->
  $("#main").remove()

window.specStartTuringEmailApp = ->
  TuringEmailApp.models = {}
  TuringEmailApp.views = {}
  TuringEmailApp.collections = {}
  TuringEmailApp.routers = {}

  $("<div />", {id: "main"}).appendTo("body")
  
  TuringEmailApp.views.mainView = new TuringEmailApp.Views.Main(
    app: TuringEmailApp
    el: $("#main")
  )
  TuringEmailApp.views.mainView.render()

  TuringEmailApp.views.toolbarView = new TuringEmailApp.Views.ToolbarView(
    app: TuringEmailApp
  )

  TuringEmailApp.models.user = new TuringEmailApp.Models.User()
  TuringEmailApp.models.userSettings = new TuringEmailApp.Models.UserSettings()
  
  TuringEmailApp.collections.emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(undefined, app: TuringEmailApp)
  TuringEmailApp.views.emailFoldersTreeView = new TuringEmailApp.Views.EmailFolders.TreeView(
    app: TuringEmailApp
    el: $("#email_folders")
    collection: TuringEmailApp.collections.emailFolders
  )

  TuringEmailApp.views.composeView = TuringEmailApp.views.mainView.composeView
  TuringEmailApp.listenTo(TuringEmailApp.views.composeView, "change:draft", TuringEmailApp.draftChanged)

  TuringEmailApp.views.createFolderView = TuringEmailApp.views.mainView.createFolderView

  TuringEmailApp.collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined, app: TuringEmailApp)
  TuringEmailApp.views.emailThreadsListView = TuringEmailApp.views.mainView.createEmailThreadsListView(TuringEmailApp.collections.emailThreads)

  TuringEmailApp.routers.emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()
  TuringEmailApp.routers.emailThreadsRouter = new TuringEmailApp.Routers.EmailThreadsRouter()
  TuringEmailApp.routers.analyticsRouter = new TuringEmailApp.Routers.AnalyticsRouter()
  TuringEmailApp.routers.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()
  TuringEmailApp.routers.settingsRouter = new TuringEmailApp.Routers.SettingsRouter()
  TuringEmailApp.routers.searchResultsRouter = new TuringEmailApp.Routers.SearchResultsRouter()

  if not specStartedHistory
    Backbone.history.start(silent: true)
    specStartedHistory = true

window.specCompareFunctions = (fExpected, f) ->
  expect(f.toString().replace(/\s/g, "")).toEqual(fExpected.toString().replace(/\s/g, ""))
    
window.specPrepareReportFetches = (server) ->
  attachmentsReportFixtures = fixture.load("reports/attachments_report.fixture.json", true);
  attachmentsReportFixture = attachmentsReportFixtures[0]

  emailVolumeReportFixtures = fixture.load("reports/email_volume_report.fixture.json", true);
  emailVolumeReportFixture = emailVolumeReportFixtures[0]

  foldersReportFixtures = fixture.load("reports/folders_report.fixture.json", true);
  foldersReportFixture = foldersReportFixtures[0]

  geoReportFixtures = fixture.load("reports/geo_report.fixture.json", true);
  geoReportFixture = geoReportFixtures[0]

  threadsFixtures = fixture.load("reports/threads_report.fixture.json", true);
  threadsFixture = threadsFixtures[0]

  listsFixtures = fixture.load("reports/lists_report.fixture.json", true);
  listsFixture = listsFixtures[0]

  contactsReportFixtures = fixture.load("reports/contacts_report.fixture.json", true);
  contactsReportFixture = contactsReportFixtures[0]

  server = sinon.fakeServer.create() if not server?
  
  server.respondWith "GET", new TuringEmailApp.Models.Reports.AttachmentsReport().url, JSON.stringify(attachmentsReportFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.EmailVolumeReport().url, JSON.stringify(emailVolumeReportFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.FoldersReport().url, JSON.stringify(foldersReportFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.GeoReport().url, JSON.stringify(geoReportFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.ThreadsReport().url, JSON.stringify(threadsFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.ListsReport().url, JSON.stringify(listsFixture)
  server.respondWith "GET", new TuringEmailApp.Models.Reports.ContactsReport().url, JSON.stringify(contactsReportFixture)

  return server
    
window.specPrepareSearchResultsFetch = (server) ->
  emailThreadSearchResultsFixtures = fixture.load("email_thread_search_results.fixture.json");
  validEmailThreadSearchResultsFixture = emailThreadSearchResultsFixtures[0]["valid"]

  server = sinon.fakeServer.create() if not server?

  server.respondWith "POST", TuringEmailApp.Collections.EmailThreadsSearchResultsCollection.SEARCH_URL,
                     JSON.stringify(validEmailThreadSearchResultsFixture)
  
  return [server, validEmailThreadSearchResultsFixture]

window.specPrepareUserSettingsFetch = (userSettings, server) ->
  userSettingsFixtures = fixture.load("user_settings.fixture.json");
  validUserSettingsFixture = userSettingsFixtures[0]["valid"]

  server = sinon.fakeServer.create() if not server?

  userSettings = new TuringEmailApp.Models.UserSettings() if not userSettings?
  server.respondWith "GET", userSettings.url, JSON.stringify(validUserSettingsFixture)

  return [server, validUserSettingsFixture]

window.specPrepareEmailFoldersFetch = (emailFolders, server) ->
  emailFoldersFixtures = fixture.load("email_folders.fixture.json")
  validEmailFoldersFixture = emailFoldersFixtures[0]["valid"]
  
  emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(undefined, app: TuringEmailApp) if not emailFolders?
  
  server = sinon.fakeServer.create() if not server?
  server.respondWith "GET", emailFolders.url, JSON.stringify(validEmailFoldersFixture)
  
  return [server, validEmailFoldersFixture]
  
window.specPrepareEmailThreadsFetch = (emailThreads, server) ->
  emailThreadsFixtures = fixture.load("email_threads.fixture.json");
  validEmailThreadsFixture = emailThreadsFixtures[0]["valid"]

  emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined, app: TuringEmailApp) if not emailThreads?

  server = sinon.fakeServer.create() if not server?
  server.respondWith "GET", emailThreads.url, JSON.stringify(validEmailThreadsFixture)

  return [server, validEmailThreadsFixture]
  
window.specPrepareEmailThreadFetch = (server) ->
  emailThreadFixtures = fixture.load("email_thread.fixture.json")
  validEmailThreadFixture = emailThreadFixtures[0]["valid"]
  
  emailThread = new TuringEmailApp.Models.EmailThread(undefined,
    app: TuringEmailApp
    emailThreadUID: validEmailThreadFixture["uid"]
  )
  
  server = sinon.fakeServer.create() if not server?
  server.respondWith "GET", emailThread.url, JSON.stringify(validEmailThreadFixture)

  return [server, emailThread, validEmailThreadFixture]
  
window.specCreateEmailThreadsListView = (server) ->
  emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined, app: TuringEmailApp)

  emailThreadsListView = new TuringEmailApp.Views.EmailThreads.ListView(
    collection: emailThreads
  )
  $("body").append(emailThreadsListView)

  validEmailThreadsFixture = FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE)
  emailThreads.reset(validEmailThreadsFixture)

  server = sinon.fakeServer.create() if not server?
  return [emailThreadsListView.$el, emailThreadsListView, emailThreads, server, validEmailThreadsFixture]

window.validateAttributes = (expectedAttributes, model, modelRendered, expectedAttributesToSkip=[]) ->
  expectedAttributes = expectedAttributes.sort()
  keys = _.keys(modelRendered).sort()
  expect(keys).toEqual(expectedAttributes)

  for key, value of modelRendered
    continue if key == "__name__"
    continue if expectedAttributesToSkip.indexOf(key) != -1

    expect(value).toEqual(model[key])

window.validateUserSettings = (userSettings, userSettingsRendered) ->
  expectedAttributes = ["id", "demo_mode_enabled", "keyboard_shortcuts_enabled", "genie_enabled", "split_pane_mode"]
  validateAttributes(expectedAttributes, userSettings, userSettingsRendered)
    
window.validateKeys = (objectJSON, expectedKeys) ->
  keys = (key for key in _.keys(objectJSON))
  keys.sort()

  expectedKeys = expectedKeys.slice().sort()
  
  expect(keys).toEqual expectedKeys

window.validateUserAttributes = (userJSON) ->
  expectedAttributes = ["email"]
  validateKeys(userJSON, expectedAttributes)
  
window.validateUserSettingsAttributes = (userSettingsJSON) ->
  expectedAttributes = ["id", "demo_mode_enabled", "keyboard_shortcuts_enabled", "genie_enabled", "split_pane_mode"]
  validateKeys(userSettingsJSON, expectedAttributes)

window.validateBrainRulesAttributes = (brainRulesJSON) ->
  expectedAttributes = ["uid", "from_address", "to_address", "subject", "list_id"]
  validateKeys(brainRulesJSON, expectedAttributes)

window.validateEmailRulesAttributes = (emailRulesJSON) ->
  expectedAttributes = ["uid", "from_address", "to_address", "subject", "list_id", "destination_folder_name"]
  validateKeys(emailRulesJSON, expectedAttributes)

window.validateEmailFolderAttributes = (emailFolderJSON) ->
  expectedAttributes = ["label_id", "name",
                         "message_list_visibility", "label_list_visibility",
                         "label_type",
                         "num_threads", "num_unread_threads"]
  validateKeys(emailFolderJSON, expectedAttributes)

window.validateEmailThreadAttributes = (emailThreadJSON) ->
  expectedAttributes = ["uid", "emails"]
  validateKeys(emailThreadJSON, expectedAttributes)
  
window.validateEmailAttributes = (emailJSON) ->
  expectedAttributes = ["auto_filed",
                        "uid", "draft_id", "message_id", "list_id",
                        "seen", "snippet", "date",
                        "from_name", "from_address",
                        "sender_name", "sender_address",
                        "reply_to_name", "reply_to_address",
                        "tos", "ccs", "bccs",
                        "subject",
                        "html_part", "text_part", "body_text",
                        "folder_ids"]
  validateKeys(emailJSON, expectedAttributes)

window.verifyReportsRendered = (parent) ->
  reportSelectors = [".attachments_report", ".email_volume_report", ".folders_report", ".geo_report",
                     ".lists_report", ".threads_report", ".contacts_report"]

  for reportSelector in reportSelectors
    reportDiv = parent.find(reportSelector)
    expect(reportDiv.length).toEqual(1)
    expect(reportDiv.html()).not.toEqual("")
