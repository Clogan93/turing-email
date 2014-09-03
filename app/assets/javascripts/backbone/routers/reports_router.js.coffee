class TuringEmailApp.Routers.ReportsRouter extends Backbone.Router
  routes:
    "email_volume_report": "showEmailVolumeReport"

  load_sample_data: (emailVolumeReport) ->
  	emailVolumeReport.set "incoming_email_data", { test : "Hello world" }
  	console.log "loading sample data."

  showEmailVolumeReport: ->
    emailVolumeReport = new TuringEmailApp.Models.EmailVolumeReport()
    this.load_sample_data emailVolumeReport
    emailVolumeReportView = new TuringEmailApp.Views.Reports.EmailVolumeReportView(
      model: emailVolumeReport
      el: $("#reports")
    )
    emailVolumeReportView.render()
