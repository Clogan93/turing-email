TuringEmailApp.Collections.Rules ||= {}

class TuringEmailApp.Collections.Rules.BrainRulesCollection extends Backbone.Collection
  model: TuringEmailApp.Models.Rules.BrainRule
  url: '/api/v1/genie_rules'
