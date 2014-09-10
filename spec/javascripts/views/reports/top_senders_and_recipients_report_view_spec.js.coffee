describe "Top Senders And Recipients Report View", ->

  beforeEach ->
    @topSendersAndRecipientsReport = new TuringEmailApp.Models.TopSendersAndRecipientsReport()
    @topSendersAndRecipientsReportView = new TuringEmailApp.Views.Reports.TopSendersAndRecipientsReportView(
      model: @topSendersAndRecipientsReport
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.TopSendersAndRecipientsReportView).toBeDefined()

  it "should have the right model", ->
    expect(@topSendersAndRecipientsReportView.model).toEqual @topSendersAndRecipientsReport

  it "loads the topSendersAndRecipientsReport template", ->
    expect(@topSendersAndRecipientsReportView.template).toEqual JST["backbone/templates/reports/top_senders_and_recipients_report"]
