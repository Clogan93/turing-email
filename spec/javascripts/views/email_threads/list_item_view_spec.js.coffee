describe "ListItemView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailThreadFixtures = fixture.load("email_thread.fixture.json");
    @validEmailThreadFixture = emailThreadFixtures[0]["valid"]

    @emailThread = new TuringEmailApp.Models.EmailThread(undefined, emailThreadUID: @validEmailThreadFixture["uid"])
    @listItemView = new TuringEmailApp.Views.EmailThreads.ListItemView(
      model: @emailThread
    )

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @emailThread.url, JSON.stringify(@validEmailThreadFixture)

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@listItemView.template).toEqual JST["backbone/templates/email_threads/list_item"]

  describe "after fetch", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    describe "#render", ->
      it "renders the list item", ->
        expect(@listItemView.el.nodeName).toEqual "TR"

        expect(@listItemView.el).toContain("td.check-mail")
        expect(@listItemView.$el.find('td.mail-contact').text().trim()).toEqual @emailThread.fromPreview()
        expect(@listItemView.$el.find('td.mail-subject').text().trim()).toEqual @emailThread.subjectPreview()
        expect(@listItemView.$el.find('td.mail-date').text().trim()).toEqual @emailThread.datePreview()

    describe "#addedToDOM", ->
      it "calls setupCheckbox when addedToDOM is called", ->
        @spy = sinon.spy(@listItemView, "setupCheckbox")
        @listItemView.addedToDOM()
        expect(@spy).toHaveBeenCalled()
        @spy.restore()

    describe "#setupClick", ->
      beforeEach ->
        @tdCheckMail = @listItemView.$el.find('td.check-mail')

      it "bind click handlers to tds", ->
        expect(@tdCheckMail).toHandle("click")
        expect(@listItemView.$el.find('td.mail-contact')).toHandle("click")
        expect(@listItemView.$el.find('td.mail-subject')).toHandle("click")
        expect(@listItemView.$el.find('td.mail-date')).toHandle("click")

      describe "when clicked", ->
        it "triggers click", ->
          spy = sinon.backbone.spy(@listItemView, "click")
          @tdCheckMail.click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#setupCheckbox", ->
      it "calls iCheck on each checkbox", ->
        @listItemView.setupCheckbox()
        diviCheck = @listItemView.$el.find("div.icheckbox_square-green")
        expect(diviCheck).toHaveClass("icheckbox_square-green")
        expect(diviCheck).toContain("input.i-checks")
        expect(diviCheck).toContain("ins.iCheck-helper")

      it "binds click events to the checkboxes", ->
        @listItemView.setupCheckbox()
        expect(@listItemView.$el.find("div.icheckbox_square-green ins")).toHandle("click")

      describe "when a checkbox is clicked", ->
        beforeEach ->
          @listItemView.setupCheckbox()

        it "calls updateCheckStyles", ->
          @spy = sinon.spy(@listItemView, "updateCheckStyles")
          @listItemView.$el.find("div.icheckbox_square-green ins").click()
          expect(@spy).toHaveBeenCalled()

        describe "when checked", ->
          beforeEach ->
            @listItemView.check()

          it "triggers unchecked", ->
            spy = sinon.backbone.spy(@listItemView, "unchecked")
            @listItemView.$el.find("div.icheckbox_square-green ins").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

        describe "when unchecked", ->
          beforeEach ->
            @listItemView.uncheck()

          it "triggers selected", ->
            spy = sinon.backbone.spy(@listItemView, "checked")
            @listItemView.$el.find("div.icheckbox_square-green ins").click()
            expect(spy).toHaveBeenCalled()
            spy.restore()

    describe "#isChecked", ->
      beforeEach ->
        @listItemView.setupCheckbox()

      it "returns false when the checkbox is not checked", ->
        expect(@listItemView.isChecked()).toBeFalsy()

      it "returns true when the checkbox is checked", ->
        @listItemView.check()
        expect(@listItemView.isChecked()).toBeTruthy()

    describe "#updateCheckStyles", ->
      beforeEach ->
        @listItemView.setupCheckbox()

      describe "when selected", ->
        beforeEach ->
          @listItemView.check()
          @listItemView.updateCheckStyles()
        
        it "adds the selected styles", ->
          expect(@listItemView.$el).toHaveClass("checked_email_thread")

      describe "when unchecked", ->
        beforeEach ->
          @listItemView.uncheck()
          @listItemView.updateCheckStyles()
        
        it "removes the selected styles", ->
          expect(@listItemView.$el).not.toHaveClass("checked_email_thread")

    describe "#toggleCheck", ->
      beforeEach ->
        @listItemView.setupCheckbox()

      describe "when checked", ->
        beforeEach ->
          @listItemView.check()

        it "unchecks the list item", ->
          spy = sinon.spy(@listItemView, "uncheck")
          @listItemView.toggleCheck()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when unchecked", ->
        beforeEach ->
          @listItemView.uncheck()

        it "checks the list item", ->
          spy = sinon.spy(@listItemView, "check")
          @listItemView.toggleCheck()
          expect(spy).toHaveBeenCalled()
          spy.restore()

    describe "#check", ->
      beforeEach ->
        @listItemView.addedToDOM()

      it "checks the list items", ->
        @listItemView.$el.removeClass("checked_email_thread")
        expect(@listItemView.$el).not.toHaveClass("checked_email_thread")
        @listItemView.check()
        expect(@listItemView.$el).toHaveClass("checked_email_thread")

      it "triggers selected", ->
        spy = sinon.backbone.spy(@listItemView, "checked")
        @listItemView.check()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "#uncheck", ->
      beforeEach ->
        @listItemView.addedToDOM()
        @listItemView.check()

      it "unchecks the list items", ->
        expect(@listItemView.$el).toHaveClass("checked_email_thread")
        @listItemView.uncheck()
        expect(@listItemView.$el).not.toHaveClass("checked_email_thread")

      it "triggers unchecked", ->
        spy = sinon.backbone.spy(@listItemView, "unchecked")
        @listItemView.uncheck()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "#select", ->
      it "adds the currently_being_read class", ->
        @listItemView.$el.removeClass("currently_being_read")
        expect(@listItemView.$el).not.toHaveClass("currently_being_read")
        @listItemView.select()
        expect(@listItemView.$el).toHaveClass("currently_being_read")

      it "triggers selected", ->
        spy = sinon.backbone.spy(@listItemView, "selected")
        @listItemView.select()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "#deselect", ->
      beforeEach ->
        @listItemView.select()

      it "removes the currently_being_read class", ->
        @listItemView.$el.addClass("currently_being_read")
        expect(@listItemView.$el).toHaveClass("currently_being_read")
        @listItemView.deselect()
        expect(@listItemView.$el).not.toHaveClass("currently_being_read")

      it "triggers deselected", ->
        spy = sinon.backbone.spy(@listItemView, "deselected")
        @listItemView.deselect()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "#markRead", ->
      it "removes the unread class", ->
        @listItemView.$el.addClass("unread")
        expect(@listItemView.$el).toHaveClass("unread")
        @listItemView.markRead()
        expect(@listItemView.$el).not.toHaveClass("unread")

      it "adds the read class", ->
        @listItemView.$el.removeClass("read")
        expect(@listItemView.$el).not.toHaveClass("read")
        @listItemView.markRead()
        expect(@listItemView.$el).toHaveClass("read")

      it "triggers markRead", ->
        spy = sinon.backbone.spy(@listItemView, "markRead")
        @listItemView.markRead()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe "#markUnread", ->
      it "removes the read class", ->
        @listItemView.$el.addClass("read")
        expect(@listItemView.$el).toHaveClass("read")
        @listItemView.markUnread()
        expect(@listItemView.$el).not.toHaveClass("read")

      it "adds the unread class", ->
        @listItemView.$el.removeClass("unread")
        expect(@listItemView.$el).not.toHaveClass("unread")
        @listItemView.markUnread()
        expect(@listItemView.$el).toHaveClass("unread")

      it "triggers markUnread", ->
        spy = sinon.backbone.spy(@listItemView, "markUnread")
        @listItemView.markUnread()
        expect(spy).toHaveBeenCalled()
        spy.restore()
