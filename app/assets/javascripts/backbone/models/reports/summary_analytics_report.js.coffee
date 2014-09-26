class TuringEmailApp.Models.SummaryAnalyticsReport extends Backbone.Model
  fetch: (options) ->
    attributes = 
      number_of_conversations: 824
      number_of_emails_received: 1039
      number_of_emails_sent: 203

    @set attributes
    options?.success?(this, {}, options)
