class TuringEmailApp.Collections.EmailRulesCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailRule
  url: '/api/v1/email_rules'
