describe "BrainRulesCollection", ->
  beforeEach ->
    brainRulesFixtures = fixture.load("rules/brain_rules.fixture.json", true)
    @validBrainRulesFixture = brainRulesFixtures[0]

    @url = "/api/v1/genie_rules"
    @brainRulesCollection = new TuringEmailApp.Collections.BrainRulesCollection()

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @url, JSON.stringify(@validBrainRulesFixture)

    @brainRulesCollection.fetch()
    @server.respond()

  afterEach ->
    @server.restore()

  it "should use the BrainRule model", ->
    expect(@brainRulesCollection.model).toEqual TuringEmailApp.Models.BrainRule

  it "has the right url", ->
    expect(@brainRulesCollection.url).toEqual @url

  describe "#fetch", ->

    it "loads the brain rules", ->
      expect(@brainRulesCollection.length).toEqual @validBrainRulesFixture.length
      expect(@brainRulesCollection.toJSON()).toEqual @validBrainRulesFixture

    it "loads the correct attributes in the model", ->
      validateAttributes(@brainRulesCollection.models[0].toJSON(), ["uid", "from_address", "to_address", "subject", "list_id"])
