describe "DelayedEmailsCollection", ->
  beforeEach ->
    @delayedEmailsCollection = new TuringEmailApp.Collections.DelayedEmailsCollection()

  it "uses the DelayedEmail model", ->
    expect(@delayedEmailsCollection.model).toEqual(TuringEmailApp.Models.DelayedEmail)

  it "has the right URL", ->
    expect(@delayedEmailsCollection.url).toEqual("/api/v1/delayed_emails")
