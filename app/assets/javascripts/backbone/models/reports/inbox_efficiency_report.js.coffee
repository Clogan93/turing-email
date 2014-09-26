class TuringEmailApp.Models.InboxEfficiencyReport extends Backbone.Model
  fetch: (options) ->
    attributes =
      average_response_time_in_minutes: 7.5
      percent_archived: 71.2
      
    @set attributes
    options?.success?(this, {}, options)
