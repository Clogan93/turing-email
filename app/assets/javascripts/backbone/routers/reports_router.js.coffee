class TuringEmailApp.Routers.ReportsRouter extends Backbone.Router
  routes:
    "email_volume_report": "showEmailVolumeReport"

  showEmailVolumeReport: ->
    emailVolumeReport = new Backbone.Model()
    emailVolumeReportView = new TuringEmailApp.Views.Reports.EmailVolumeReportView(
      model: emailVolumeReport
      el: $("#email_content")
    )
    emailVolumeReportView.render()
