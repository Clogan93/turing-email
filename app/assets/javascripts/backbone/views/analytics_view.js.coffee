class TuringEmailApp.Views.AnalyticsView extends Backbone.View
  template: JST["backbone/templates/analytics"]

  remove: ->
    @$el.remove()

  render: ->
    TuringEmailApp.restyle_other_elements()

    @$el.html(@template())

    TuringEmailApp.reportsRouter.showAttachmentsReport "#attachments_report"
    TuringEmailApp.reportsRouter.showEmailVolumeReport "#email_volume_report"
    TuringEmailApp.reportsRouter.showGeoReport "#geo_report"
    TuringEmailApp.reportsRouter.showListsReport "#lists_report"
    TuringEmailApp.reportsRouter.showThreadsReport "#threads_report"
    TuringEmailApp.reportsRouter.showContactsReport "#contacts_report"

    return this
