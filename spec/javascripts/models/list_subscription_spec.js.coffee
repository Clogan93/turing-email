describe "ListSubscription", ->
  beforeEach ->
    @listSubscription = new TuringEmailApp.Models.ListSubscription()

  it "uses uid as idAttribute", ->
    expect(@listSubscription.idAttribute).toEqual("uid")
