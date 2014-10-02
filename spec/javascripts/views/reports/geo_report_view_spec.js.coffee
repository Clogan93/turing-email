describe "GeoReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @geoReport = new TuringEmailApp.Models.GeoReport()

    @geoReportDiv = $("<div />", {id: "geo_report"}).appendTo("body")
    @geoReportView = new TuringEmailApp.Views.Reports.GeoReportView(
      model: @geoReport
      el: @geoReportDiv
    )

    geoReportFixtures = fixture.load("reports/geo_report.fixture.json", true);
    @geoReportFixture = geoReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.GeoReport().url, JSON.stringify(@geoReportFixture)

  afterEach ->
    @server.restore()
    @geoReportDiv.remove()

  it "has the right template", ->
    expect(@geoReportView.template).toEqual JST["backbone/templates/reports/geo_report"]

  describe "#render", ->
    beforeEach ->
      @geoReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@geoReportDiv).toBeVisible()
      expect(@geoReportDiv).toContainHtml("Reports <small>geography</small>")

      divIDs = ["geo_chart_div"]

      for divID in divIDs
        div = $("#" + divID)
        expect(div).toBeVisible()

  describe "#getGoogleChartData", ->
    beforeEach ->
      @geoReport.fetch()
      @server.respond()

      @expectedGoogleChartData = JSON.parse('{"cityStats":[["City","Number of Emails"],["",335],["New York",16],["Mountain View",20],["Manchester",66],["Chicago",27],["Houston",2],["San Antonio",5],["Indianapolis",13],["Scottsdale",6],["Ashburn",14],["San Francisco",37],["Edinburgh",9],["Atlanta",26],["San Bruno",14],["Seattle",12],["Atherton",8],["Woodbridge",1],["San Jose",2],["Dallas",4],["Stanford",4],["Leicester",1],["Lehi",1],["Menlo Park",1],["Sacramento",2],["Lansing",2],["Rancho Cucamonga",2]]}')

    it "converts the model into Google Chart data format", ->
      # TODO not sure how to test because what it renders is dependent on the current date
      #expect(@geoReportView.getGoogleChartData()).toEqual(@expectedGoogleChartData)
 