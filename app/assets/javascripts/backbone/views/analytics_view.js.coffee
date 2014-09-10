TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.AnalyticsView extends Backbone.View
  template: JST["backbone/templates/analytics"]

  initialize: ->
    return

  remove: ->
    @$el.remove()

  render: ->
    TuringEmailApp.reportsRouter.restyle_other_elements()

    @$el.html(@template())

    TuringEmailApp.reportsRouter.showAttachmentsReport "#attachments_report"
    TuringEmailApp.reportsRouter.showEmailVolumeReport "#email_volume_report"
    TuringEmailApp.reportsRouter.showGeoReport "#geo_report"
    TuringEmailApp.reportsRouter.showListsReport "#lists_report"
    TuringEmailApp.reportsRouter.showThreadsReport "#threads_report"
    TuringEmailApp.reportsRouter.showContactsReport "#contacts_report"

    return this
