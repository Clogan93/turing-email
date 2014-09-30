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

    it "sets up bulk action buttons", ->
      spy = sinon.spy(TuringEmailApp.views.toolbarView, "setupBulkActionButtons")
      TuringEmailApp.views.toolbarView.setupButtons()
      expect(spy).toHaveBeenCalled()

    it "sets up the search button", ->
      spy = sinon.spy(TuringEmailApp.views.toolbarView, "setupSearchButton")
      TuringEmailApp.views.toolbarView.setupButtons()
      expect(spy).toHaveBeenCalled()

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

  describe "#setupBulkActionButtons", ->
    
    it "should handle clicks", ->
      expect(TuringEmailApp.views.toolbarView.$el.find("#all_bulk_action")).toHandle("click")
      expect(TuringEmailApp.views.toolbarView.$el.find("#none_bulk_action")).toHandle("click")
      expect(TuringEmailApp.views.toolbarView.$el.find("#read_bulk_action")).toHandle("click")
      expect(TuringEmailApp.views.toolbarView.$el.find("#unread_bulk_action")).toHandle("click")

    describe "when all_bulk_action is clicked", ->
      it "triggers selectAll", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "selectAll")
        TuringEmailApp.views.toolbarView.$el.find("#all_bulk_action").click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      it "checks the all checkbox", ->
        TuringEmailApp.views.toolbarView.$el.find("#all_bulk_action").click()
        expect(TuringEmailApp.views.toolbarView.selectAllIsChecked()).toBeTruthy()

    describe "when none_bulk_action is clicked", ->
      it "triggers deselectAll", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "deselectAll")
        TuringEmailApp.views.toolbarView.$el.find("#none_bulk_action").click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      it "unchecks the all checkbox", ->
        TuringEmailApp.views.toolbarView.$el.find("#none_bulk_action").click()
        expect(TuringEmailApp.views.toolbarView.selectAllIsChecked()).toBeFalsy()

    describe "when read_bulk_action is clicked", ->
      it "triggers selectAllRead", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "selectAllRead")
        TuringEmailApp.views.toolbarView.$el.find("#read_bulk_action").click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "when unread_bulk_action is clicked", ->
      it "triggers selectAllUnread", ->
        spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "selectAllUnread")
        TuringEmailApp.views.toolbarView.$el.find("#unread_bulk_action").click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

  describe "#selectAllIsChecked", ->
    
    describe "when the all checkbox is checked", ->
      beforeEach ->
        TuringEmailApp.views.toolbarView.divSelectAllICheck.iCheck("check")

      it "returns true", ->
        expect(TuringEmailApp.views.toolbarView.selectAllIsChecked()).toBeTruthy()

    describe "when the all checkbox is not checked", ->
      beforeEach ->
        TuringEmailApp.views.toolbarView.divSelectAllICheck.iCheck("uncheck")

      it "returns false", ->
        expect(TuringEmailApp.views.toolbarView.selectAllIsChecked()).toBeFalsy()

  describe "#deselectAllCheckbox", ->
    
    it "unchecks the all checkbox", ->
      spy = sinon.spy(TuringEmailApp.views.toolbarView.divSelectAllICheck, "iCheck")
      TuringEmailApp.views.toolbarView.deselectAllCheckbox()
      expect(spy).toHaveBeenCalled()
      expect(spy).toHaveBeenCalledWith("uncheck")
      spy.restore()

  describe "#currentEmailFolderChanged", ->
    beforeEach ->
      @newEmailFolderID = TuringEmailApp.collections.emailFolders.models[0].get("uid")

    it "updates the title", ->
      updateTitleSpy = sinon.spy(TuringEmailApp.views.toolbarView, "updateTitle")
      TuringEmailApp.views.toolbarView.currentEmailFolderChanged(TuringEmailApp, @newEmailFolderID)
      expect(updateTitleSpy).toHaveBeenCalled()
      updateTitleSpy.restore()

    it "updates the pagination text", ->
      updatePaginationTextSpy = sinon.spy(TuringEmailApp.views.toolbarView, "updatePaginationText")
      TuringEmailApp.views.toolbarView.currentEmailFolderChanged(TuringEmailApp, @newEmailFolderID)
      expect(updatePaginationTextSpy).toHaveBeenCalled()
      updatePaginationTextSpy.restore()

  describe "#emailFoldersChanged", ->

    it "renders", ->
      spy = sinon.spy(TuringEmailApp.views.toolbarView, "render")
      TuringEmailApp.views.toolbarView.emailFoldersChanged()
      expect(spy).toHaveBeenCalled()
      spy.restore()
