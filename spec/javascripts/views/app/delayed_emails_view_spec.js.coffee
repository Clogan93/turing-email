describe "DelayedEmailsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @delayedEmails = new TuringEmailApp.Collections.DelayedEmailsCollection(FactoryGirl.createLists("DelayedEmail", FactoryGirl.SMALL_LIST_SIZE))
    @delayedEmailsView = new TuringEmailApp.Views.App.DelayedEmailsView(collection: @delayedEmails)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@delayedEmailsView.template).toEqual JST["backbone/templates/app/delayed_emails"]
  
  describe "#render", ->
    beforeEach ->
      @setupButtonsStub = sinon.stub(@delayedEmailsView, "setupButtons")

      @delayedEmailsView.render()
      
    afterEach ->
      @setupButtonsStub.restore()
      
    it "calls setupButtons", ->
      expect(@setupButtonsStub).toHaveBeenCalled()
        
  describe "after render", ->
    beforeEach ->
      @delayedEmailsView.render()
      
    describe "#setupButtons", ->
      beforeEach ->
        @onDeleteDelayedEmailClick = sinon.stub(@delayedEmailsView, "onDeleteDelayedEmailClick")
        
        @delayedEmailsView.setupButtons()
        
      afterEach ->
        @onDeleteDelayedEmailClick.restore()

      it "handles delete-delayed-email-button click", ->
        expect(@delayedEmailsView.$el.find(".delete-delayed-email-button")).toHandle("click")

      it "delete-delayed-email-button click", ->
        @delayedEmailsView.$el.find(".delete-delayed-email-button").click()
        expect(@onDeleteDelayedEmailClick).toHaveBeenCalled()

    describe "after setupButtons", ->
      beforeEach ->
        @delayedEmailsView.setupButtons()

      describe "#onDeleteDelayedEmailClick", ->
        beforeEach ->
          @event =
            currentTarget: $(@delayedEmailsView.$el.find(".delete-delayed-email-button")[0])

          @triggerStub = sinon.stub(@delayedEmailsView, "trigger", ->)

          @delayedEmailsView.onDeleteDelayedEmailClick(@event)

        afterEach ->
          @triggerStub.restore()

        it "triggers deleteDelayedEmailClicked", ->
          expect(@triggerStub).toHaveBeenCalledWith("deleteDelayedEmailClicked", @delayedEmailsView, @delayedEmails.at(0).get("uid"))
