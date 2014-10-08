describe "EmailFoldersRouter", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailFoldersRouter = new TuringEmailApp.Routers.EmailFoldersRouter()

    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the expected routes", ->
    expect(@emailFoldersRouter.routes["email_folder/:emailFolderID"]).toEqual "showFolder"

  describe "email_folder/:emailFolderID", ->
    beforeEach ->
      @folderName = "test"
      
      @spy = sinon.spy(TuringEmailApp, "currentEmailFolderIs")
      @emailFoldersRouter.navigate "email_folder/" + @folderName, trigger: true

    afterEach ->
      @spy.restore()

    it "shows the folder", ->
      expect(@spy).toHaveBeenCalledWith(@folderName)
