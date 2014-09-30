describe "ToolbarView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailFoldersFixtures = fixture.load("email_folders.fixture.json")
    @validEmailFoldersFixture = emailFoldersFixtures[0]["valid"]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", TuringEmailApp.collections.emailFolders.url, JSON.stringify(@validEmailFoldersFixture)
    
    TuringEmailApp.collections.emailFolders.fetch()
    @server.respond()

    TuringEmailApp.views.toolbarView.render()

  it "should be defined", ->
    expect(TuringEmailApp.Views.ToolbarView).toBeDefined()

  it "loads the list item template", ->
    expect(TuringEmailApp.views.toolbarView.template).toEqual JST["backbone/templates/toolbar_view"]

  describe "#setupButtons", ->
    
    it "should handle clicks", ->
      expect(TuringEmailApp.views.toolbarView.$el.find("i.fa-eye").parent()).toHandle("click")
      expect(TuringEmailApp.views.toolbarView.$el.find("i.fa-eye-slash").parent()).toHandle("click")
      expect(TuringEmailApp.views.toolbarView.$el.find("i.fa-archive").parent()).toHandle("click")
      expect(TuringEmailApp.views.toolbarView.$el.find("i.fa-trash-o").parent()).toHandle("click")
      expect(TuringEmailApp.views.toolbarView.$el.find("#paginate_left_link")).toHandle("click")
      expect(TuringEmailApp.views.toolbarView.$el.find("#paginate_right_link")).toHandle("click")
      expect(TuringEmailApp.views.toolbarView.$el.find(".label_as_link")).toHandle("click")
      expect(TuringEmailApp.views.toolbarView.$el.find(".move_to_folder_link")).toHandle("click")
      expect(TuringEmailApp.views.toolbarView.$el.find("#refresh_button")).toHandle("click")

    describe "when i.fa-eye is clicked", ->
      it "triggers readClicked", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "readClicked")
        TuringEmailApp.views.toolbarView.$el.find("i.fa-eye").parent().click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "when i.fa-eye-slash is clicked", ->
      it "triggers unreadClicked", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "unreadClicked")
        TuringEmailApp.views.toolbarView.$el.find("i.fa-eye-slash").parent().click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "when i.fa-archive is clicked", ->
      it "triggers archiveClicked", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "archiveClicked")
        TuringEmailApp.views.toolbarView.$el.find("i.fa-archive").parent().click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "when i.fa-trash-o is clicked", ->
      it "triggers trashClicked", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "trashClicked")
        TuringEmailApp.views.toolbarView.$el.find("i.fa-trash-o").parent().click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "when #paginate_left_link is clicked", ->
      it "triggers leftArrowClicked", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "leftArrowClicked")
        TuringEmailApp.views.toolbarView.$el.find("#paginate_left_link").click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "when #paginate_right_link is clicked", ->
      it "triggers rightArrowClicked", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "rightArrowClicked")
        TuringEmailApp.views.toolbarView.$el.find("#paginate_right_link").click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "when .label_as_link is clicked", ->
      it "triggers labelAsClicked", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "labelAsClicked")
        TuringEmailApp.views.toolbarView.$el.find(".label_as_link").click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "when .move_to_folder_link is clicked", ->
      it "triggers moveToFolderClicked", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "moveToFolderClicked")
        TuringEmailApp.views.toolbarView.$el.find(".move_to_folder_link").click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "when #refresh_button is clicked", ->
      it "triggers refreshClicked", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "refreshClicked")
        TuringEmailApp.views.toolbarView.$el.find("#refresh_button").click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

  describe "#currentEmailFolderChanged", ->
    beforeEach ->
      @newEmailFolderID = TuringEmailApp.collections.emailFolders.models[0].get("uid")

    it "calls updateTitle with emailFolderID", ->
      updateTitleSpy = sinon.spy(TuringEmailApp.views.toolbarView, "updateTitle")
      TuringEmailApp.views.toolbarView.currentEmailFolderChanged(TuringEmailApp, @newEmailFolderID)
      expect(updateTitleSpy).toHaveBeenCalled()
      updateTitleSpy.restore()

    it "calls updatePaginationText with emailFolderID", ->
      updatePaginationTextSpy = sinon.spy(TuringEmailApp.views.toolbarView, "updatePaginationText")
      TuringEmailApp.views.toolbarView.currentEmailFolderChanged(TuringEmailApp, @newEmailFolderID)
      expect(updatePaginationTextSpy).toHaveBeenCalled()
      updatePaginationTextSpy.restore()

  describe "#emailFoldersChanged", ->

    it "calls render", ->
      spy = sinon.spy(TuringEmailApp.views.toolbarView, "render")
      TuringEmailApp.views.toolbarView.emailFoldersChanged()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe "#selectAllIsChecked", ->
    
    describe "when divSelectAllICheck is checked", ->
      beforeEach ->
        TuringEmailApp.views.toolbarView.divSelectAllICheck.iCheck("check")

      it "returns true", ->
        expect(TuringEmailApp.views.toolbarView.selectAllIsChecked()).toBeTruthy()

    describe "when divSelectAllICheck is not checked", ->
      beforeEach ->
        TuringEmailApp.views.toolbarView.divSelectAllICheck.iCheck("uncheck")

      it "returns false", ->
        expect(TuringEmailApp.views.toolbarView.selectAllIsChecked()).toBeFalsy()

  describe "#deselectAllCheckbox", ->
    
    it "calls iCheck on divSelectAllICheck with uncheck", ->
      spy = sinon.spy(TuringEmailApp.views.toolbarView.divSelectAllICheck, "iCheck")
      TuringEmailApp.views.toolbarView.deselectAllCheckbox()
      expect(spy).toHaveBeenCalled()
      expect(spy).toHaveBeenCalledWith("uncheck")
      spy.restore()
