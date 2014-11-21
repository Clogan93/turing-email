describe "QuickReplyView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailThreadAttributes = FactoryGirl.create("EmailThread")
    emailThreadAttributes.emails.push(FactoryGirl.create("Email", draft_id: "draft"))
    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
      app: TuringEmailApp
      emailThreadUID: emailThreadAttributes.uid
      demoMode: false
    )
    
    @emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: @emailThread
    )
    @emailThreadView.render()
    $("body").append(@emailThreadView.$el)

    @quickReplyView = new TuringEmailApp.Views.App.QuickReplyView(
      el: @emailThreadView.$el.find(".email-response-btn-group").first()
      emailThreadView: @emailThreadView
    )

  afterEach ->
    @emailThreadView.$el.remove()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@quickReplyView.template).toEqual JST["backbone/templates/email_threads/quick_reply_dropdown"]

  it "correctly sets the email thread view instance variable", ->
    expect(@quickReplyView.emailThreadView).toEqual @emailThreadView

  describe "#render", ->
    beforeEach ->
      @quickReplyView.render()

    it "attaches click handlers to the single click communication links in the dropdown", ->
      expect(@quickReplyView.$el.parent().find(".single-click-communication-link")).toHandle("click")

    describe "when a quick reply link is clicked", ->
      beforeEach ->
        TuringEmailApp.views.composeView.render()
        $("body").append(TuringEmailApp.views.composeView.$el)

      it "triggers replyClicked", ->
        spy = sinon.backbone.spy(@quickReplyView.emailThreadView, "replyClicked")
        @quickReplyView.$el.parent().find(".single-click-communication-link").first().click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      # TODO figure out how to test the insertion of: Sent with Turing Quick Response.
