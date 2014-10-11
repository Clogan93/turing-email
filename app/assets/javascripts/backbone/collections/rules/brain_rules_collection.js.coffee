class TuringEmailApp.Collections.BrainRulesCollection extends Backbone.Collection
  model: TuringEmailApp.Models.BrainRule
  url: '/api/v1/genie_rules'
