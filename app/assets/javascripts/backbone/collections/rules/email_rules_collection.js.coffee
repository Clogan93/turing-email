TuringEmailApp.Collections.Rules ||= {}

class TuringEmailApp.Collections.Rules.EmailRulesCollection extends Backbone.Collection
  model: TuringEmailApp.Models.Rules.EmailRule
  url: '/api/v1/email_rules'
