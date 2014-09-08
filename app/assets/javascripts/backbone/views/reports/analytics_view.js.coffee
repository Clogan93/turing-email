TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.AnalyticsView extends Backbone.View
  template: JST["backbone/templates/reports/analytics"]

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
    TuringEmailApp.reportsRouter.showInboxEfficiencyReport "#inbox_efficiency_report"
    TuringEmailApp.reportsRouter.showSummaryAnalyticsReport "#summary_analytics_report"
    TuringEmailApp.reportsRouter.showThreadsReport "#threads_report"
    TuringEmailApp.reportsRouter.showTopSendersAndRecipientsReport "#top_senders_and_recipients_report"
    TuringEmailApp.reportsRouter.showWordCountReport "#word_count_report"

    return this
