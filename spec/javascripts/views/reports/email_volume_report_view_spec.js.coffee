describe "Email Volume Report View", ->

  beforeEach ->
    @emailVolumeReport = new TuringEmailApp.Models.EmailVolumeReport()
    @emailVolumeReportView = new TuringEmailApp.Views.Reports.EmailVolumeReportView(
      model: @emailVolumeReport
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.EmailVolumeReportView).toBeDefined()

  it "should have the right model", ->
    expect(@emailVolumeReportView.model).toEqual @emailVolumeReport

  it "loads the emailVolumeReport template", ->
    expect(@emailVolumeReportView.template).toEqual JST["backbone/templates/reports/email_volume_report"]
