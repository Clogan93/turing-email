describe "Contacts Report View", ->

  beforeEach ->
    @contactsReport = new TuringEmailApp.Models.ContactsReport()
    @contactsReportView = new TuringEmailApp.Views.Reports.ContactsReportView(
      model: @contactsReport
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.ContactsReportView).toBeDefined()

  it "should have the right model", ->
    expect(@contactsReportView.model).toEqual @contactsReport

  it "loads the contactsReport template", ->
    expect(@contactsReportView.template).toEqual JST["backbone/templates/reports/contacts_report"]
