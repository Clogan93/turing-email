describe "RecommendedRulesReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @recommendedRulesReport = new TuringEmailApp.Models.RecommendedRulesReport()

    @recommendedRulesReportDiv = $("<div />", {id: "recommended_rules_report"}).appendTo("body")
    @recommendedRulesReportView = new TuringEmailApp.Views.Reports.RecommendedRulesReportView(
      model: @recommendedRulesReport
      el: @recommendedRulesReportDiv
    )

    recommendedRulesReportFixtures = fixture.load("reports/recommended_rules_report.fixture.json", true);
    @recommendedRulesReportFixture = recommendedRulesReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.RecommendedRulesReport().url, JSON.stringify(@recommendedRulesReportFixture)

  afterEach ->
    @server.restore()
    @recommendedRulesReportDiv.remove()

  it "has the right template", ->
    expect(@recommendedRulesReportView.template).toEqual JST["backbone/templates/reports/recommended_rules_report"]

  describe "#render", ->
    beforeEach ->
      @recommendedRulesReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@recommendedRulesReportDiv).toBeVisible()
      expect(@recommendedRulesReportDiv).toContainHtml("Reports <small>recommended rules</small>")

    it "renders the genie rule explanation text", ->
      expect(@recommendedRulesReportDiv).toContainHtml("<p>The genie has been working extra hard to keep your inbox clean, and recommends that you make the following rules so that these emails skip your inbox during the day:</p>")

    it "renders the email rules", ->
      expect(@recommendedRulesReportDiv).toContainHtml('Rule: filter emails from ' + @recommendedRulesReport.get("rules_recommended")[0].list_id + " into " + @recommendedRulesReport.get("rules_recommended")[0].destination_folder + '.')
      expect(@recommendedRulesReportDiv).toContainHtml('<a class="rule_recommendation_link" href="' + @recommendedRulesReport.get("rules_recommended")[0].list_id + '">Create rule.</a>')

    it "shows the reports", ->
      spy = sinon.spy(TuringEmailApp, "showReports")
      @recommendedRulesReportView.render()
      expect(spy).toHaveBeenCalled()

    it "sets up the recommended rules links", ->
      spy = sinon.spy(@recommendedRulesReportView, "setupRecommendedRulesLinks")
      @recommendedRulesReportView.render()
      expect(spy).toHaveBeenCalled()

  describe "#setupRecommendedRulesLinks", ->
    beforeEach ->
      @recommendedRulesReport.fetch()
      @server.respond()

    it "hooks the click action on the rules recommendation link", ->
      expect(@recommendedRulesReportView.$el.find(".rule_recommendation_link")).toHandle("click")

    describe "when the rules recommendation link is clicked", ->
      beforeEach ->
        @server = sinon.fakeServer.create()
        @server.respondWith "POST", @sendDraftURL, JSON.stringify({})

      afterEach ->
        @server.restore()

      it "prevents the default link action", ->
        selector = ".rule_recommendation_link"
        spyOnEvent(selector, "click")
        
        @recommendedRulesReportView.$el.find(".rule_recommendation_link").click()
        
        expect("click").toHaveBeenPreventedOn(selector)

      it "shows the success alert", ->
        @recommendedRulesReportView.$el.find(".rule_recommendation_link").click()
        expect(@recommendedRulesReportDiv).toContainHtml('<br />
                              <div class="col-md-4 alert alert-success" role="alert">
                                You have successfully created an email rule!
                              </div>')

      it "hides the rule recommendation link", ->
        @recommendedRulesReportView.$el.find(".rule_recommendation_link").click()
        expect(@recommendedRulesReportDiv).not.toContainHtml('<a class="rule_recommendation_link" href="' + @recommendedRulesReport.get("rules_recommended")[0].list_id + '">Create rule.</a>')
        
      it "should post the email rule to the server", ->
        @recommendedRulesReportView.$el.find(".rule_recommendation_link").click()
        expect(@server.requests.length).toEqual 1
        request = @server.requests[0]
        expect(request.method).toEqual "POST"
        expect(request.url).toEqual "/api/v1/email_rules"
