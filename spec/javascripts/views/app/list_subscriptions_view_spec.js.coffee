describe "ListSubscriptionsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @listSubscriptions = new TuringEmailApp.Collections.ListSubscriptionsCollection(FactoryGirl.createLists("ListSubscription", FactoryGirl.SMALL_LIST_SIZE))
    @listSubscriptions.at(1).set("unsubscribed", true)
    @listSubscriptionsView = new TuringEmailApp.Views.App.ListSubscriptionsView(collection: @listSubscriptions)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@listSubscriptionsView.template).toEqual JST["backbone/templates/app/list_subscriptions"]
  
  describe "#render", ->
    beforeEach ->
      @setupButtonsStub = sinon.stub(@listSubscriptionsView, "setupButtons")

      @listSubscriptionsView.render()
      
    afterEach ->
      @setupButtonsStub.restore()
      
    it "calls setupButtons", ->
      expect(@setupButtonsStub).toHaveBeenCalled()
        
  describe "after render", ->
    beforeEach ->
      @listSubscriptionsView.render()
      
    describe "#setupButtons", ->
      beforeEach ->
        @onUnsubscribeListClick = sinon.stub(@listSubscriptionsView, "onUnsubscribeListClick")
        @onResubscribeListClick = sinon.stub(@listSubscriptionsView, "onResubscribeListClick")
        
        @listSubscriptionsView.setupButtons()
        
      afterEach ->
        @onUnsubscribeListClick.restore()
        @onResubscribeListClick.restore()

      it "handles unsubscribe-list-button click", ->
        expect(@listSubscriptionsView.$el.find(".unsubscribe-list-button")).toHandle("click")

      it "unsubscribe-list-button click", ->
        @listSubscriptionsView.$el.find(".unsubscribe-list-button").click()
        expect(@onUnsubscribeListClick).toHaveBeenCalled()

      it "handles resubscribe-list-button click", ->
        expect(@listSubscriptionsView.$el.find(".resubscribe-list-button")).toHandle("click")

      it "resubscribe-list-button click", ->
        @listSubscriptionsView.$el.find(".resubscribe-list-button").click()
        expect(@onResubscribeListClick).toHaveBeenCalled()

    describe "after setupButtons", ->
      beforeEach ->
        @listSubscriptionsView.setupButtons()

      describe "#onUnsubscribeListClick", ->
        beforeEach ->
          @event =
            currentTarget: $(@listSubscriptionsView.$el.find(".unsubscribe-list-button")[0])

          @triggerStub = sinon.stub(@listSubscriptionsView, "trigger", ->)

          @listSubscriptionsView.onUnsubscribeListClick(@event)

        afterEach ->
          @triggerStub.restore()

        it "triggers unsubscribeListClicked", ->
          expect(@triggerStub).toHaveBeenCalledWith("unsubscribeListClicked", @listSubscriptionsView, @listSubscriptions.at(0))

      describe "#onResubscribeListClick", ->
        beforeEach ->
          @event =
            currentTarget: $(@listSubscriptionsView.$el.find(".resubscribe-list-button")[0])

          @triggerStub = sinon.stub(@listSubscriptionsView, "trigger", ->)

          @listSubscriptionsView.onResubscribeListClick(@event)

        afterEach ->
          @triggerStub.restore()

        it "triggers resubscribeListClicked", ->
          expect(@triggerStub).toHaveBeenCalledWith("resubscribeListClicked", @listSubscriptionsView, @listSubscriptions.at(1))
