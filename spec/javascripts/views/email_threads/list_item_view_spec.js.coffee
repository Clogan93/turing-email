describe "ListItemView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailThreadFixtures = fixture.load("email_thread.fixture.json");
    @validEmailThreadFixture = emailThreadFixtures[0]["valid"]

    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadUID: @validEmailThreadFixture["uid"])
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
      expect(@listItemView.el).toHaveAttr("name", @emailThread.uid)
      expect(@listItemView.el).toHaveData("isDraft", true)
      expect(@listItemView.el).toHaveData("emailThreadUID", @emailThread.uid)

      expect(@listItemView.el).toContain("td.check-mail")
      expect(@listItemView.$el.find('td.mail-contact').text().trim()).toEqual @emailThread.get("emails")[0].from_name
      expect(@listItemView.$el.find('td.mail-subject').text().trim()).toEqual @emailThread.get("emails")[0].subject
      # TODO test date
