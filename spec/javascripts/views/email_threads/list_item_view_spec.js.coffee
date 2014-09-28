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

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @emailThread.url, JSON.stringify(@validEmailThreadFixture)

  afterEach ->
    @server.restore()

  it "has the right template", ->
    expect(@listItemView.template).toEqual JST["backbone/templates/email_threads/list_item"]

  describe "#render", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()
      
    it "renders the list item", ->
      expect(@listItemView.el.nodeName).toEqual "TR"
      expect(@listItemView.el).toHaveCss({cursor: "pointer"})

      expect(@listItemView.el).toContain("td.check-mail")
      expect(@listItemView.$el.find('td.mail-contact').text().trim()).toEqual @emailThread.get("emails")[0].from_name
      expect(@listItemView.$el.find('td.mail-subject').text().trim()).toEqual @emailThread.get("emails")[0].subject
      # TODO test date

  describe "#addedToDOM", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "calls setupCheckbox when addedToDOM is called", ->
      @spy = sinon.spy(@listItemView, "setupCheckbox")
      @listItemView.addedToDOM()
      expect(@spy).toHaveBeenCalled()

  describe "#setupClick", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "bind click handlers to tds", ->
      expect(@listItemView.$el.find('td.check-mail')).toHandle("click")
      expect(@listItemView.$el.find('td.mail-contact')).toHandle("click")
      expect(@listItemView.$el.find('td.mail-subject')).toHandle("click")
      expect(@listItemView.$el.find('td.mail-date')).toHandle("click")

      # TODO make a backbone spy to test the backbone event is triggered upon click.

  describe "#setupCheckbox", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "", ->
      return

  describe "#toggleSelect", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "", ->
      return

  describe "#select", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "", ->
      return

  describe "#deselect", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "", ->
      return

  describe "#highlight", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "", ->
      return

  describe "#unhighlight", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "", ->
      return

  describe "#markRead", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "", ->
      return

  describe "#markUnread", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "", ->
      return
