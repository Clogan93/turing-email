class TuringEmailApp.Views.AnalyticsView extends Backbone.View
  template: JST["backbone/templates/analytics"]

  className: "analytics-view"

  initialize: ->
    @reports =
      ".attachments_report":
        model: TuringEmailApp.Models.Reports.AttachmentsReport
        view: TuringEmailApp.Views.Reports.AttachmentsReportView
  
      ".email_volume_report":
        model: TuringEmailApp.Models.Reports.EmailVolumeReport
        view: TuringEmailApp.Views.Reports.EmailVolumeReportView
  
      ".folders_report":
        model: TuringEmailApp.Models.Reports.FoldersReport
        view: TuringEmailApp.Views.Reports.FoldersReportView
  
      ".geo_report":
        model: TuringEmailApp.Models.Reports.GeoReport
        view: TuringEmailApp.Views.Reports.GeoReportView
  
      ".lists_report":
        model: TuringEmailApp.Models.Reports.ListsReport
        view: TuringEmailApp.Views.Reports.ListsReportView
  
      ".threads_report":
        model: TuringEmailApp.Models.Reports.ThreadsReport
        view: TuringEmailApp.Views.Reports.ThreadsReportView
  
      ".contacts_report":
        model: TuringEmailApp.Models.Reports.ContactsReport
        view: TuringEmailApp.Views.Reports.ContactsReportView
  
  render: ->
    @$el.html(@template())

    for reportSelector, reportClasses of @reports
      reportModel = new reportClasses.model()
      reportView = new reportClasses.view(
        model: reportModel
        el: @$el.find(reportSelector)
      )
      
      reportModel.fetch()
    
    @$el.attr("name", "analytics_view")

    return this
