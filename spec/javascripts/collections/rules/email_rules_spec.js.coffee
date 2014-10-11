describe "EmailRulesCollection", ->
  beforeEach ->
    emailRulesFixtures = fixture.load("rules/email_rules.fixture.json", true)
    @validEmailRulesFixture = emailRulesFixtures[0]

    @url = "/api/v1/email_rules"
    @emailRulesCollection = new TuringEmailApp.Collections.Rules.EmailRulesCollection()

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @url, JSON.stringify(@validEmailRulesFixture)

    @emailRulesCollection.fetch()
    @server.respond()

  afterEach ->
    @server.restore()

  it "should use the EmailRule model", ->
    expect(@emailRulesCollection.model).toEqual TuringEmailApp.Models.Rules.EmailRule

  it "has the right url", ->
    expect(@emailRulesCollection.url).toEqual @url

  describe "#fetch", ->

    it "loads the email rules", ->
      expect(@emailRulesCollection.length).toEqual @validEmailRulesFixture.length
      expect(@emailRulesCollection.toJSON()).toEqual @validEmailRulesFixture

    it "loads the correct attributes in the model", ->
      validateAttributes(@emailRulesCollection.models[0].toJSON(), ["uid", "from_address", "to_address", "subject", "list_id", "destination_folder_name"])
