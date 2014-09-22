class TuringEmailApp.Views.AnalyticsView extends Backbone.View
  template: JST["backbone/templates/analytics"]

  remove: ->
    @$el.remove()

  render: ->
    TuringEmailApp.restyle_other_elements()

    @$el.html(@template())

    TuringEmailApp.routers.reportsRouter.showAttachmentsReport "#attachments_report"
    TuringEmailApp.routers.reportsRouter.showEmailVolumeReport "#email_volume_report"
    TuringEmailApp.routers.reportsRouter.showGeoReport "#geo_report"
    TuringEmailApp.routers.reportsRouter.showListsReport "#lists_report"
    TuringEmailApp.routers.reportsRouter.showThreadsReport "#threads_report"
    TuringEmailApp.routers.reportsRouter.showContactsReport "#contacts_report"

    return this
