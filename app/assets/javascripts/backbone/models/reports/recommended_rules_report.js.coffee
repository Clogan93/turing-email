class TuringEmailApp.Models.RecommendedRulesReport extends Backbone.Model
  url: "/api/v1/email_rules/recommended_rules"

  parse: (response, options) ->
    parsedResponse = {}

    ruleRecommendations = []

    for ruleRecommendation in response
      ruleRecommendations.push(ruleRecommendation)

    parsedResponse["ruleRecommendations"] = ruleRecommendations

    return parsedResponse
