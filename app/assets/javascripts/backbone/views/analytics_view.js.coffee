class TuringEmailApp.Views.AnalyticsView extends Backbone.View
  template: JST["backbone/templates/analytics"]

  render: ->
    @$el.html(@template())

    TuringEmailApp.routers.reportsRouter.showAttachmentsReport "attachments_report"
    TuringEmailApp.routers.reportsRouter.showEmailVolumeReport "email_volume_report"
    TuringEmailApp.routers.reportsRouter.showGeoReport "geo_report"
    TuringEmailApp.routers.reportsRouter.showListsReport "lists_report"
    TuringEmailApp.routers.reportsRouter.showThreadsReport "threads_report"
    TuringEmailApp.routers.reportsRouter.showTopContactsReport "contacts_report"
    
    @$el.attr("name", "analytics_view")

    return this
