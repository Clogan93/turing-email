describe "EmailFoldersRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  it "has the expected routes", ->
    expect(@emailFoldersRouter.routes["inbox"]).toEqual "showInbox"
    expect(@emailFoldersRouter.routes["email_folder/:emailFolderID"]).toEqual "showFolder"

  describe "inbox", ->
    beforeEach ->
      @spy = sinon.spy(TuringEmailApp, "currentEmailFolderIs")
      @emailFoldersRouter.navigate "inbox", trigger: true
      
    afterEach ->
      @spy.restore()

    it "shows the inbox", ->
      expect(@spy.calledWith("INBOX")).toBeTruthy()

  describe "email_folder/:emailFolderID", ->
    beforeEach ->
      @folderName = "test"
      
      @spy = sinon.spy(TuringEmailApp, "currentEmailFolderIs")
      @emailFoldersRouter.navigate "email_folder/" + @folderName, trigger: true

    afterEach ->
      @spy.restore()

    it "shows the folder", ->
      expect(@spy.calledWith(@folderName)).toBeTruthy()
