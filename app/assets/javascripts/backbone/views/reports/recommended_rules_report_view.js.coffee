TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.RecommendedRulesReportView extends Backbone.View
  template: JST["backbone/templates/reports/recommended_rules_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  setup_recommended_rules_links: ->
    $(".rule_recommendation_link").click (event) ->
      event.preventDefault()

      $.post "/api/v1/email_rules", { list_id: $(@).attr("href"), destination_folder: $(@).text() }, (data) =>
        console.log data
        return

  render: ->
    TuringEmailApp.reportsRouter.restyle_other_elements()

    @$el.html(@template(@model.toJSON()))

    @setup_recommended_rules_links()

    return this
