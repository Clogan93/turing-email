describe "DelayedEmailsCollection", ->
  beforeEach ->
    @delayedEmailsCollection = new TuringEmailApp.Collections.DelayedEmailsCollection()

  it "uses the DelayedEmail model", ->
    expect(@delayedEmailsCollection.model).toEqual(TuringEmailApp.Models.DelayedEmail)

  it "has the right URL", ->
    expect(@delayedEmailsCollection.url).toEqual("/api/v1/delayed_emails")

  describe "with models", ->
    beforeEach ->
      @delayedEmailsCollection.add(FactoryGirl.createLists("DelayedEmail", FactoryGirl.SMALL_LIST_SIZE))

    describe "Events", ->
      describe "#modelRemoved", ->
        beforeEach ->
          @delayedEmail = @delayedEmailsCollection.at(0)
          @triggerStub = sinon.spy(@delayedEmail, "trigger")

          @delayedEmailsCollection.remove(@delayedEmail)

        afterEach ->
          @triggerStub.restore()

        it "triggers removedFromCollection on the delayed email", ->
          expect(@triggerStub).toHaveBeenCalledWith("removedFromCollection", @delayedEmailsCollection)

      describe "#modelsReset", ->
        beforeEach ->
          @modelRemovedStub = sinon.stub(@delayedEmailsCollection, "modelRemoved", ->)

          @oldDelayedEmails = @delayedEmailsCollection.models
          @delayedEmails = FactoryGirl.createLists("DelayedEmail", FactoryGirl.SMALL_LIST_SIZE)
          @delayedEmailsCollection.reset(@delayedEmails)

        afterEach ->
          @modelRemovedStub.restore()

        it "calls modelRemoved for each model model removed", ->
          for delayedEmail in @oldDelayedEmails
            expect(@modelRemovedStub).toHaveBeenCalledWith(delayedEmail)
