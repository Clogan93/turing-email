class TuringEmailApp.Routers.ReportsRouter extends Backbone.Router
  routes:
    "email_volume_report": "showEmailVolumeReport"

  loadSampleData: (emailVolumeReport) ->
    emailVolumeReport.set "incomingEmailData", { 
      people : [
        ['David Gobaud', 3],
        ['Joe Blogs', 1],
        ['John Smith', 1],
        ['Marissa Mayer', 1],
        ['Elon Musk', 2]
      ],
      title : "Incoming Email Volume Chart"
    }
    emailVolumeReport.set "outgoingEmailData", { 
      people : [
        ['Edmund Curtis', 10],
        ['Stuart Cohen', 4],
        ['Nancy Rios', 3],
        ['Pamela White', 1],
        ['Joanne Park', 2]
      ],
      title : "Outgoing Email Volume Chart"
    }

  showEmailVolumeReport: ->
    emailVolumeReport = new TuringEmailApp.Models.EmailVolumeReport()
    this.loadSampleData emailVolumeReport
    emailVolumeReportView = new TuringEmailApp.Views.Reports.EmailVolumeReportView(
      model: emailVolumeReport
      el: $("#reports")
    )
    emailVolumeReportView.render()
