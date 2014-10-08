describe "ToolbarView", ->
  beforeEach ->
    specStartTuringEmailApp()

    [@server] = specPrepareEmailFoldersFetch()
    TuringEmailApp.collections.emailFolders.fetch()
    @server.respond()
    
  afterEach ->
    @server.restore()
    
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(TuringEmailApp.views.toolbarView.template).toEqual JST["backbone/templates/toolbar_view"]

  describe "#initialize", ->

    it "adds a listener for change:currentEmailFolder that calls currentEmailFolderChanged", ->
      # TODO figure out how to test this, and then write tests for it.
      return

    it "adds a listener for change:emailFolders that calls emailFoldersChanged", ->
      # TODO figure out how to test this, and then write tests for it.
      return

  describe "after render", ->
    beforeEach ->
      TuringEmailApp.views.toolbarView.emailFoldersChanged(TuringEmailApp, TuringEmailApp.collections.emailFolders)
      TuringEmailApp.views.toolbarView.render()

    describe "#render", ->

      it "renders as a DIV", ->
        expect(TuringEmailApp.views.toolbarView.el.nodeName).toEqual "DIV"

      it "sets up the all checkbox", ->
        spy = sinon.spy(TuringEmailApp.views.toolbarView, "setupAllCheckbox")
        TuringEmailApp.views.toolbarView.render()
        expect(spy).toHaveBeenCalled()

      it "sets up the buttons", ->
        spy = sinon.spy(TuringEmailApp.views.toolbarView, "setupButtons")
        TuringEmailApp.views.toolbarView.render()
        expect(spy).toHaveBeenCalled()

      it "sets the select all checkbox element", ->
        expect(TuringEmailApp.views.toolbarView.divAllCheckbox).toEqual TuringEmailApp.views.toolbarView.$el.find("div.icheckbox_square-green")

      it "doesn't crash when there is an empty folders collection", ->
        TuringEmailApp.collections.emailFolders = null
        expect(TuringEmailApp.views.toolbarView.render()).toEqual TuringEmailApp.views.toolbarView

    describe "#setupAllCheckbox", ->

      it "sets up the all checkbox", ->
        iChecks = TuringEmailApp.views.toolbarView.$el.find("div.icheckbox_square-green")
        expect(iChecks).toHaveClass("icheckbox_square-green")
        expect(iChecks).toContain("input.i-checks")
        expect(iChecks).toContain("ins.iCheck-helper")

      it "should make the check all checkbox handle clicks", ->
        expect(TuringEmailApp.views.toolbarView.$el.find("div.icheckbox_square-green ins")).toHandle("click")

      describe "when the all checkbox element is clicked", ->

        describe "when the select all checkbox element is checked", ->
          beforeEach ->
            TuringEmailApp.views.toolbarView.divAllCheckbox.iCheck("uncheck")

          it "should trigger select all", ->
            spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "checkAllClicked")
            TuringEmailApp.views.toolbarView.$el.find("div.icheckbox_square-green ins").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

        describe "when the select all checkbox element is not checked", ->
          beforeEach ->
            TuringEmailApp.views.toolbarView.divAllCheckbox.iCheck("check")

          it "should trigger deselect all", ->
            spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "uncheckAllClicked")
            TuringEmailApp.views.toolbarView.$el.find("div.icheckbox_square-green ins").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

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
        it "triggers checkAllClicked", ->
          spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "checkAllClicked")
          TuringEmailApp.views.toolbarView.$el.find("#all_bulk_action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "checks the all checkbox", ->
          TuringEmailApp.views.toolbarView.$el.find("#all_bulk_action").click()
          expect(TuringEmailApp.views.toolbarView.allCheckboxIsChecked()).toBeTruthy()

      describe "when none_bulk_action is clicked", ->
        it "triggers uncheckAllClicked", ->
          spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "uncheckAllClicked")
          TuringEmailApp.views.toolbarView.$el.find("#none_bulk_action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

        it "unchecks the all checkbox", ->
          TuringEmailApp.views.toolbarView.$el.find("#none_bulk_action").click()
          expect(TuringEmailApp.views.toolbarView.allCheckboxIsChecked()).toBeFalsy()

      describe "when read_bulk_action is clicked", ->
        it "triggers checkAllReadClicked", ->
          spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "checkAllReadClicked")
          TuringEmailApp.views.toolbarView.$el.find("#read_bulk_action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when unread_bulk_action is clicked", ->
        it "triggers checkAllUnreadClicked", ->
          spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "checkAllUnreadClicked")
          TuringEmailApp.views.toolbarView.$el.find("#unread_bulk_action").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#setupSearchButton", ->

      it "should set up the search input handle change events", ->
        expect(TuringEmailApp.views.toolbarView.$el.find("#search_input")).toHandle("change")

      it "should set up the search input handle keypress events", ->
        expect(TuringEmailApp.views.toolbarView.$el.find("#search_input")).toHandle("keypress")

      describe "when the search input changes", ->

        it "update the href attribute of the search button link", ->
          TuringEmailApp.views.toolbarView.$el.find("#search_input").val("hello")
          TuringEmailApp.views.toolbarView.$el.find("#search_input").change()
          expect(TuringEmailApp.views.toolbarView.$el.find("a#search_button_link").attr("href")).toEqual "#search/hello"

      describe "when the keypress event fires", ->

        describe "when the keypress event is the enter key", ->

          it "triggers searchClicked", ->
            spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "searchClicked")
            e = $.Event("keypress")
            e.which = 13
            TuringEmailApp.views.toolbarView.$el.find("#search_input").trigger(e);
            expect(spy).toHaveBeenCalled()
            expect(spy).toHaveBeenCalledWith(TuringEmailApp.views.toolbarView)
            #TODO write a test checking for the second argument
            spy.restore()

        describe "when the keypress event is not the enter key", ->

          it "does not call the searchClicked", ->
            spy = sinon.backbone.spy(TuringEmailApp.views.toolbarView, "searchClicked")
            e = $.Event("keypress")
            e.which = 10
            TuringEmailApp.views.toolbarView.$el.find("#search_input").trigger(e);
            expect(spy).not.toHaveBeenCalled()
            spy.restore()

    describe "#allCheckboxIsChecked", ->

      describe "when the all checkbox is checked", ->
        beforeEach ->
          TuringEmailApp.views.toolbarView.divAllCheckbox.iCheck("check")

        it "returns true", ->
          expect(TuringEmailApp.views.toolbarView.allCheckboxIsChecked()).toBeTruthy()

      describe "when the all checkbox is not checked", ->
        beforeEach ->
          TuringEmailApp.views.toolbarView.divAllCheckbox.iCheck("uncheck")

        it "returns false", ->
          expect(TuringEmailApp.views.toolbarView.allCheckboxIsChecked()).toBeFalsy()

    describe "#uncheckAllCheckbox", ->

      it "unchecks the all checkbox", ->
        spy = sinon.spy(TuringEmailApp.views.toolbarView.divAllCheckbox, "iCheck")
        TuringEmailApp.views.toolbarView.uncheckAllCheckbox()
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith("uncheck")
        spy.restore()

    describe "#updateTitle", ->
      beforeEach ->
        @emailFolder = TuringEmailApp.collections.emailFolders.models[0]
        TuringEmailApp.views.toolbarView.updateTitle @emailFolder

      it "updates the label name", ->
        expect(TuringEmailApp.views.toolbarView.$el.find(".label_name").text()).toEqual @emailFolder.get("name")

      it "updates badge count", ->
        badgeText = TuringEmailApp.views.toolbarView.$el.find(".label_count_badge").text()
        expect(badgeText).toEqual("(" + @emailFolder.get("num_unread_threads") + ")")

      describe "when the email folder's badget string is empty", ->

        it "sets the badge to empty", ->
          TuringEmailApp.views.toolbarView.updateTitle "SENT"
          badgeText = TuringEmailApp.views.toolbarView.$el.find(".label_count_badge").text()
          expect(badgeText).toEqual ""

      describe "when the email folder ID is not found locally", ->

        it "calls update title again", ->
          @spy = sinon.spy(TuringEmailApp.views.toolbarView, "updateTitle")
          TuringEmailApp.views.toolbarView.updateTitle "non-existent email folder ID"

          waitsFor ->
            return @spy.callCount == 5

    describe "#updatePaginationText", ->
      beforeEach ->
        @emailFolder = TuringEmailApp.collections.emailFolders.models[0]
        
        @validatePaginationText = ->
          totalEmailsNumber = parseInt(TuringEmailApp.views.toolbarView.$el.find("#total_emails_number").text())
          expect(totalEmailsNumber).toEqual @emailFolder.get("num_threads")
  
          startNumber = parseInt(TuringEmailApp.views.toolbarView.$el.find("#start_number").text())
          expect(startNumber).toEqual ((@page - 1) * TuringEmailApp.Models.UserSettings.EmailThreadsPerPage + 1)


          lastThreadNumber = @page * TuringEmailApp.Models.UserSettings.EmailThreadsPerPage
          if lastThreadNumber > totalEmailsNumber
            lastThreadNumber = totalEmailsNumber

          endNumber = parseInt(TuringEmailApp.views.toolbarView.$el.find("#end_number").text())
          expect(endNumber).toEqual lastThreadNumber
        
      describe "first page", ->
        beforeEach ->
          @page = 1

          TuringEmailApp.views.toolbarView.updatePaginationText @emailFolder, @page

        it "updates the pagination text", ->
          @validatePaginationText()

      describe "last page", ->
        beforeEach ->
          @page = @emailFolder.get("num_threads") % TuringEmailApp.Models.UserSettings.EmailThreadsPerPage + 1
          
          TuringEmailApp.views.toolbarView.updatePaginationText @emailFolder, @page

        it "updates the pagination text", ->
          @validatePaginationText()

    describe "TuringEmailApp Events", ->
    
      describe "#currentEmailFolderChanged", ->
        beforeEach ->
          @updateTitleSpy = sinon.spy(TuringEmailApp.views.toolbarView, "updateTitle")
          @updatePaginationTextSpy = sinon.spy(TuringEmailApp.views.toolbarView, "updatePaginationText")
  
        afterEach ->
          @updateTitleSpy.restore()
          @updatePaginationTextSpy.restore()
          
        describe "with an email folder", ->
          beforeEach ->
            TuringEmailApp.views.toolbarView.currentEmailFolder = null
            TuringEmailApp.views.toolbarView.currentEmailFolderPage = 0
            
            @emailFolder = TuringEmailApp.collections.emailFolders.models[0]
            @emailFolderPage = 1
            
            TuringEmailApp.views.toolbarView.currentEmailFolderChanged(TuringEmailApp, @emailFolder, @emailFolderPage)
          
          it "updates the current email folder variables", ->
            expect(TuringEmailApp.views.toolbarView.currentEmailFolder).toEqual(@emailFolder)
            expect(TuringEmailApp.views.toolbarView.currentEmailFolderPage).toEqual(@emailFolderPage)
            
          it "updates the title", ->
            expect(@updateTitleSpy).toHaveBeenCalledWith(@emailFolder)
    
          it "updates the pagination text", ->
            expect(@updatePaginationTextSpy).toHaveBeenCalledWith(@emailFolder, @emailFolderPage)
            
        describe "without an email folder", ->
          beforeEach ->
            TuringEmailApp.views.toolbarView.currentEmailFolder = TuringEmailApp.collections.emailFolders.models[0]
            TuringEmailApp.views.toolbarView.currentEmailFolderPage = 1
            
            @emailFolder = null
            @emailFolderPage = 0

            TuringEmailApp.views.toolbarView.currentEmailFolderChanged(TuringEmailApp, @emailFolder, @emailFolderPage)

          it "updates the current email folder variables", ->
            expect(TuringEmailApp.views.toolbarView.currentEmailFolder).toEqual(@emailFolder)
            expect(TuringEmailApp.views.toolbarView.currentEmailFolderPage).toEqual(@emailFolderPage)

          it "updates the title", ->
            expect(@updateTitleSpy).toHaveBeenCalledWith(@emailFolder)

          it "updates the pagination text", ->
            expect(@updatePaginationTextSpy).toHaveBeenCalledWith(@emailFolder, @emailFolderPage)
  
      describe "#emailFoldersChanged", ->
        beforeEach ->
          @renderSpy = sinon.spy(TuringEmailApp.views.toolbarView, "render")
          TuringEmailApp.views.toolbarView.emailFoldersChanged()
          
        afterEach ->
          @renderSpy.restore()
          
        it "triggers render", ->
          expect(@renderSpy).toHaveBeenCalled()
  
      describe "#emailFolderUnreadCountChanged", ->
        beforeEach ->
          @emailFolder = TuringEmailApp.collections.emailFolders.models[0]
          @spy = sinon.spy(TuringEmailApp.views.toolbarView, "updateTitle")
          
          TuringEmailApp.views.toolbarView.emailFolderUnreadCountChanged(TuringEmailApp, @emailFolder)
          
        afterEach ->
          @spy.restore()
          
        it "updates the title with the emailFodler", ->
          expect(@spy).toHaveBeenCalledWith(@emailFolder)
