describe "Inbox Efficiency Report View", ->

  beforeEach ->
    @inboxEfficiencyReport = new TuringEmailApp.Models.InboxEfficiencyReport()
    @inboxEfficiencyReportView = new TuringEmailApp.Views.Reports.InboxEfficiencyReportView(
      model: @inboxEfficiencyReport
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.InboxEfficiencyReportView).toBeDefined()

  it "should have the right model", ->
    expect(@inboxEfficiencyReportView.model).toEqual @inboxEfficiencyReport

  it "loads the inboxEfficiencyReport template", ->
    expect(@inboxEfficiencyReportView.template).toEqual JST["backbone/templates/reports/inbox_efficiency_report"]
