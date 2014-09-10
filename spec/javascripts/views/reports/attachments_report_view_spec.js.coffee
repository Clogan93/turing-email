describe "AttachmentsReportView", ->

  beforeEach ->
    @attachmentsReport = new TuringEmailApp.Models.AttachmentsReport()
    @attachmentsReportView = new TuringEmailApp.Views.Reports.AttachmentsReportView(
      model: @attachmentsReport
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.AttachmentsReportView).toBeDefined()
 
  it "should have the right model", ->
    expect(@attachmentsReportView.model).toEqual @attachmentsReport

  it "loads the attachment report template", ->
    expect(@attachmentsReportView.template).toEqual JST["backbone/templates/reports/attachments_report"]
