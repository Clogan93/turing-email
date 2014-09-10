describe "AttachmentsReportView", ->

  beforeEach ->
    @attachmentsReport = new TuringEmailApp.Models.AttachmentsReport()
    @attachmentsReportView = new TuringEmailApp.Views.Reports.AttachmentsReportView(
      model: @attachmentsReport
    )
    TuringEmailApp.user = new TuringEmailApp.Models.User()
    TuringEmailApp.reportsRouter = new TuringEmailApp.Routers.ReportsRouter()

  it "should be defined", ->
    expect(TuringEmailApp.Views.Reports.AttachmentsReportView).toBeDefined()
 
  it "should have the right model", ->
    expect(@attachmentsReportView.model).toEqual @attachmentsReport

  it "loads the attachment report template", ->
    expect(@attachmentsReportView.template).toEqual JST["backbone/templates/reports/attachments_report"]

  # describe "when render is called", ->

  #   beforeEach ->
  #     @fixtures = fixture.load("reports/attachments_report.fixture.json", "user.fixture.json", true)

  #     @validUser = @fixtures[1]["valid"]
  #     @attachmentsReportFixture = @fixtures[0]

  #     @server = sinon.fakeServer.create()

  #     @server.respondWith "GET", "/api/v1/users/current", JSON.stringify(@validUser)
  #     TuringEmailApp.user.fetch()
  #     @server.respond()

  #     @server.respondWith "GET", "/api/v1/emails/attachments_report", JSON.stringify(@attachmentsReportFixture)

  #     # @attachmentsReport.fetch()
  #     TuringEmailApp.reportsRouter.showAttachmentsReport()
  #     @server.respond()

  #     console.log @attachmentsReport

  #     return

  #   afterEach ->
  #     @server.restore()

  #   it "should have the root element be a div", ->
  #     expect(@attachmentsReportView.el.nodeName).toEqual "DIV"

  #   it "should render the number of attachments chart title", ->
  #     console.log $("#reports")
  #     console.log @attachmentsReportView.el
  #     console.log @attachmentsReportView.$el.find('#num_attachments_chart_div')
  #     console.log @attachmentsReportView.$el.find('#num_attachments_chart_div').find("div:contains('Number of Attachments')")

    # it "should render the attachment file size chart title", ->

    # it "should render the attributes of all the email threads", ->
    #   #Set up lists
    #   fromNames = []
    #   subjects = []
    #   snippets = []
    #   links = []

    #   #Collect Attributes from the rendered DOM.
    #   @listView.$el.find('td.mail-ontact a').each ->
    #     fromNames.push $(this).text().trim()
    #   @listView.$el.find('td.mail-subject a').each ->
    #     subjects.push $(this).text().trim()
    #   # Snippets are no longer included in the list view.
    #   # @listView.$el.find('.email_snippet').each ->
    #   #   snippets.push $(this).text().trim()
    #   @listView.$el.find('a').each ->
    #     links.push $(this).attr("href")
    #   links = _.uniq(links, false)

    #   #Run expectations
    #   for emailThread, index in @attachmentsReport.models
    #     email = emailThread.get("emails")[0]
        
    #     expect(fromNames[index]).toEqual email.from_name
    #     expect(subjects[index]).toEqual email.subject
    #     #expect(snippets[index]).toEqual email.snippet
    #     expect(links[index]).toEqual "#email_thread#" + emailThread.get("uid")
