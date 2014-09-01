describe "ListItemView", ->

  beforeEach ->
    @emailThread = new TuringEmailApp.Models.EmailThread()
    @emailThread.url = "/api/v1/email_threads"
    @listItemView = new TuringEmailApp.Views.EmailThreads.ListItemView(
      model: @emailThread
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.EmailThreads.ListItemView).toBeDefined()
 
   it "should have the right model", ->
    expect(@listItemView.model).toEqual @emailThread

  it "loads the list item template", ->
    expect(@listItemView.template).toEqual JST["backbone/templates/email_threads/list_item"]

  describe "when render is called", ->

    beforeEach ->
      @fixtures = fixture.load("email_thread.fixture.json", true)

      @validEmailThread = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email_threads", JSON.stringify(@validEmailThread)

      @server.respond()
      @emailThread.fetch()
      return

    afterEach ->
      @server.restore()

     it "should have the root element be a tr", ->
      expect(@listItemView.el.nodeName).toEqual "TR"

    it "should render the from_name attribute", ->
      console.log @emailThread
      console.log @listItemView
      expect(true).toEqual false

    it "should render the from_address attribute", ->
      expect(true).toEqual false

    it "should render the subject attribute", ->
      expect(true).toEqual false

    it "should render the snippet attribute", ->
      expect(true).toEqual false
