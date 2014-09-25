describe "EmailFoldersRouter", ->
  specStartTuringEmailApp()

  beforeEach ->
    @emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  it "has the expected routes", ->
    expect(@emailFoldersRouter.routes["inbox"]).toEqual "showInbox"
    expect(@emailFoldersRouter.routes["folder/:folder_id"]).toEqual "showFolder"

  describe "inbox", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "currentEmailFolderIs")
      @emailFoldersRouter.navigate "inbox", trigger: true
      
    afterEach ->
      @spy.restore()

    it "shows the inbox", ->
      expect(@spy.calledWith("INBOX")).toBeTruthy()

  describe "folder#:folder_id", ->
    beforeEach ->
      @testFolderName = "test"
      
      @spy = sinon.spy(TuringEmailApp, "currentEmailFolderIs")
      @emailFoldersRouter.navigate "folder/" + @testFolderName, trigger: true

    afterEach ->
      @spy.restore()

    it "shows the folder", ->
      expect(@spy.calledWith(@testFolderName)).toBeTruthy()
      