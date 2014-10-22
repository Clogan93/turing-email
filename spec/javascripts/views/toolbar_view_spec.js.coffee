describe "ToolbarView", ->
  beforeEach ->
    specStartTuringEmailApp()

    [@server] = specPrepareEmailFoldersFetch()
    TuringEmailApp.collections.emailFolders.fetch()
    @server.respond()
    
    @toolbarView = TuringEmailApp.views.toolbarView
    
  afterEach ->
    @server.restore()
    
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@toolbarView.template).toEqual JST["backbone/templates/toolbar/toolbar_view"]

  describe "#initialize", ->

    it "adds a listener for change:currentEmailFolder that calls currentEmailFolderChanged", ->
      # TODO figure out how to test this, and then write tests for it.
      return

    it "adds a listener for change:emailFolders that calls emailFoldersChanged", ->
      # TODO figure out how to test this, and then write tests for it.
      return

  describe "after render", ->
    beforeEach ->
      @toolbarView.emailFoldersChanged(TuringEmailApp, TuringEmailApp.collections.emailFolders)
      @toolbarView.render()

    describe "#render", ->

      it "renders as a DIV", ->
        expect(@toolbarView.el.nodeName).toEqual "DIV"

      it "sets up the all checkbox", ->
        spy = sinon.spy(@toolbarView, "setupAllCheckbox")
        @toolbarView.render()
        expect(spy).toHaveBeenCalled()

      it "sets up the buttons", ->
        spy = sinon.spy(@toolbarView, "setupButtons")
        @toolbarView.render()
        expect(spy).toHaveBeenCalled()

      it "sets the select all checkbox element", ->
        expect(@toolbarView.divAllCheckbox).toEqual @toolbarView.$el.find("div.icheckbox_square-green")

      it "doesn't crash when there is an empty folders collection", ->
        TuringEmailApp.collections.emailFolders = null
        expect(@toolbarView.render()).toEqual @toolbarView

    describe "#setupAllCheckbox", ->

      it "sets up the all checkbox", ->
        iChecks = @toolbarView.$el.find("div.icheckbox_square-green")
        expect(iChecks).toHaveClass("icheckbox_square-green")
        expect(iChecks).toContain("input.i-checks")
        expect(iChecks).toContain("ins.iCheck-helper")

      it "should make the check all checkbox handle clicks", ->
        expect(@toolbarView.$el.find("div.icheckbox_square-green ins")).toHandle("click")

      describe "when the all checkbox element is clicked", ->

        describe "when the select all checkbox element is checked", ->
          beforeEach ->
            @toolbarView.divAllCheckbox.iCheck("uncheck")

          it "should trigger select all", ->
            spy = sinon.backbone.spy(@toolbarView, "checkAllClicked")
            @toolbarView.$el.find("div.icheckbox_square-green ins").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

        describe "when the select all checkbox element is not checked", ->
          beforeEach ->
            @toolbarView.divAllCheckbox.iCheck("check")

          it "should trigger deselect all", ->
            spy = sinon.backbone.spy(@toolbarView, "uncheckAllClicked")
            @toolbarView.$el.find("div.icheckbox_square-green ins").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

    describe "#setupButtons", ->

      it "should handle clicks", ->
        expect(@toolbarView.$el.find(".mark_as_read").parent()).toHandle("click")
        expect(@toolbarView.$el.find(".mark_as_unread").parent()).toHandle("click")
        expect(@toolbarView.$el.find("i.fa-archive").parent()).toHandle("click")
        expect(@toolbarView.$el.find("i.fa-trash-o").parent()).toHandle("click")
        expect(@toolbarView.$el.find("#paginate_left_link")).toHandle("click")
        expect(@toolbarView.$el.find("#paginate_right_link")).toHandle("click")
        expect(@toolbarView.$el.find(".label_as_link")).toHandle("click")
        expect(@toolbarView.$el.find(".move_to_folder_link")).toHandle("click")
        expect(@toolbarView.$el.find("#refresh_button")).toHandle("click")

      it "sets up bulk action buttons", ->
        spy = sinon.spy(@toolbarView, "setupBulkActionButtons")
        @toolbarView.setupButtons()
        expect(spy).toHaveBeenCalled()

      describe "when i.fa-eye is clicked", ->
        it "triggers readClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "readClicked")
          @toolbarView.$el.find(".mark_as_read").parent().click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when i.fa-eye-slash is clicked", ->
        it "triggers unreadClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "unreadClicked")
          @toolbarView.$el.find(".mark_as_unread").parent().click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when i.fa-archive is clicked", ->
        it "triggers archiveClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "archiveClicked")
          @toolbarView.$el.find("i.fa-archive").parent().click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when i.fa-trash-o is clicked", ->
        it "triggers trashClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "trashClicked")
          @toolbarView.$el.find("i.fa-trash-o").parent().click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when #paginate_left_link is clicked", ->
        it "triggers leftArrowClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "leftArrowClicked")
          @toolbarView.$el.find("#paginate_left_link").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when #paginate_right_link is clicked", ->
        it "triggers rightArrowClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "rightArrowClicked")
          @toolbarView.$el.find("#paginate_right_link").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when .label_as_link is clicked", ->
        it "triggers labelAsClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "labelAsClicked")
          @toolbarView.$el.find(".label_as_link").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when .move_to_folder_link is clicked", ->
        it "triggers moveToFolderClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "moveToFolderClicked")
          @toolbarView.$el.find(".move_to_folder_link").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when #refresh_button is clicked", ->
        it "triggers refreshClicked", ->
          @toolbarView.$el.find("#refresh_button").show()
          spy = sinon.backbone.spy(@toolbarView, "refreshClicked")
          @toolbarView.$el.find("#refresh_button").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#setupBulkActionButtons", ->

      it "should handle clicks", ->
        expect(@toolbarView.$el.find("#all_bulk_action")).toHandle("click")
        expect(@toolbarView.$el.find("#none_bulk_action")).toHandle("click")
        expect(@toolbarView.$el.find("#read_bulk_action")).toHandle("click")
        expect(@toolbarView.$el.find("#unread_bulk_action")).toHandle("click")

      describe "when all_bulk_action is clicked", ->
        it "triggers checkAllClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "checkAllClicked")
          @toolbarView.$el.find("#all_bulk_action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "checks the all checkbox", ->
          @toolbarView.$el.find("#all_bulk_action").click()
          expect(@toolbarView.allCheckboxIsChecked()).toBeTruthy()

      describe "when none_bulk_action is clicked", ->
        it "triggers uncheckAllClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "uncheckAllClicked")
          @toolbarView.$el.find("#none_bulk_action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "unchecks the all checkbox", ->
          @toolbarView.$el.find("#none_bulk_action").click()
          expect(@toolbarView.allCheckboxIsChecked()).toBeFalsy()

      describe "when read_bulk_action is clicked", ->
        it "triggers checkAllReadClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "checkAllReadClicked")
          @toolbarView.$el.find("#read_bulk_action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when unread_bulk_action is clicked", ->
        it "triggers checkAllUnreadClicked", ->
          spy = sinon.backbone.spy(@toolbarView, "checkAllUnreadClicked")
          @toolbarView.$el.find("#unread_bulk_action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#allCheckboxIsChecked", ->

      describe "when the all checkbox is checked", ->
        beforeEach ->
          @toolbarView.divAllCheckbox.iCheck("check")

        it "returns true", ->
          expect(@toolbarView.allCheckboxIsChecked()).toBeTruthy()

      describe "when the all checkbox is not checked", ->
        beforeEach ->
          @toolbarView.divAllCheckbox.iCheck("uncheck")

        it "returns false", ->
          expect(@toolbarView.allCheckboxIsChecked()).toBeFalsy()

    describe "#uncheckAllCheckbox", ->

      it "unchecks the all checkbox", ->
        spy = sinon.spy(@toolbarView.divAllCheckbox, "iCheck")
        @toolbarView.uncheckAllCheckbox()
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith("uncheck")
        spy.restore()

    describe "#updatePaginationText", ->
      beforeEach ->
        @emailFolder = TuringEmailApp.collections.emailFolders.models[0]
        
        @validatePaginationText = ->
          totalEmailsNumber = parseInt(@toolbarView.$el.find("#total_emails_number").text())
          expect(totalEmailsNumber).toEqual @emailFolder.get("num_threads")
  
          startNumber = parseInt(@toolbarView.$el.find("#start_number").text())
          expect(startNumber).toEqual ((@page - 1) * TuringEmailApp.Models.UserSettings.EmailThreadsPerPage + 1)


          lastThreadNumber = @page * TuringEmailApp.Models.UserSettings.EmailThreadsPerPage
          if lastThreadNumber > totalEmailsNumber
            lastThreadNumber = totalEmailsNumber

          endNumber = parseInt(@toolbarView.$el.find("#end_number").text())
          expect(endNumber).toEqual lastThreadNumber
        
      describe "first page", ->
        beforeEach ->
          @page = 1

          @toolbarView.updatePaginationText @emailFolder, @page

        it "updates the pagination text", ->
          @validatePaginationText()

      describe "last page", ->
        beforeEach ->
          @page = @emailFolder.get("num_threads") % TuringEmailApp.Models.UserSettings.EmailThreadsPerPage + 1
          
          @toolbarView.updatePaginationText @emailFolder, @page

        it "updates the pagination text", ->
          @validatePaginationText()

    describe "#showMoveToFolderMenu", ->
      beforeEach ->
        spyOnEvent(@toolbarView.$el.find("#moveToFolderDropdownMenu"), "click.bs.dropdown")
        @toolbarView.showMoveToFolderMenu()
      
      it "shows the move to folder menu", ->
        expect("click.bs.dropdown").toHaveBeenTriggeredOn(@toolbarView.$el.find("#moveToFolderDropdownMenu"))
          
    describe "TuringEmailApp Events", ->
    
      describe "#currentEmailFolderChanged", ->
        beforeEach ->
          @updatePaginationTextSpy = sinon.spy(@toolbarView, "updatePaginationText")
  
        afterEach ->
          @updatePaginationTextSpy.restore()
          
        describe "with an email folder", ->
          beforeEach ->
            @toolbarView.currentEmailFolder = null
            @toolbarView.currentEmailFolderPage = 0
            
            @emailFolder = TuringEmailApp.collections.emailFolders.models[0]
            @emailFolderPage = 1
            
            @toolbarView.currentEmailFolderChanged(TuringEmailApp, @emailFolder, @emailFolderPage)
          
          it "updates the current email folder variables", ->
            expect(@toolbarView.currentEmailFolder).toEqual(@emailFolder)
            expect(@toolbarView.currentEmailFolderPage).toEqual(@emailFolderPage)

          it "updates the pagination text", ->
            expect(@updatePaginationTextSpy).toHaveBeenCalledWith(@emailFolder, @emailFolderPage)
            
        describe "without an email folder", ->
          beforeEach ->
            @toolbarView.currentEmailFolder = TuringEmailApp.collections.emailFolders.models[0]
            @toolbarView.currentEmailFolderPage = 1
            
            @emailFolder = null
            @emailFolderPage = 0

            @toolbarView.currentEmailFolderChanged(TuringEmailApp, @emailFolder, @emailFolderPage)

          it "updates the current email folder variables", ->
            expect(@toolbarView.currentEmailFolder).toEqual(@emailFolder)
            expect(@toolbarView.currentEmailFolderPage).toEqual(@emailFolderPage)

          it "updates the pagination text", ->
            expect(@updatePaginationTextSpy).toHaveBeenCalledWith(@emailFolder, @emailFolderPage)
  
      describe "#emailFoldersChanged", ->
        beforeEach ->
          @renderSpy = sinon.spy(@toolbarView, "render")
          @toolbarView.emailFoldersChanged()
          
        afterEach ->
          @renderSpy.restore()
          
        it "triggers render", ->
          expect(@renderSpy).toHaveBeenCalled()
  
      describe "#emailFolderUnreadCountChanged", ->
        beforeEach ->
          @emailFolder = TuringEmailApp.collections.emailFolders.models[0]

          @toolbarView.emailFolderUnreadCountChanged(TuringEmailApp, @emailFolder)

        it "does nothing", ->
          return
