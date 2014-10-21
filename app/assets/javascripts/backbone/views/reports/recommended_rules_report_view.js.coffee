TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.RecommendedRulesReportView extends Backbone.View
  template: JST["backbone/templates/reports/recommended_rules_report"]

  className: "report-view"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    modelJSON = @model.toJSON()
    @$el.html(@template(modelJSON))
    
    @setupRecommendedRulesLinks()

    report = new Report(@)
    report.setupReportsDropdown()

    return this

  setupRecommendedRulesLinks: ->
    @$el.find(".rule_recommendation_link").click (event) ->
      event.preventDefault()

      $(@).parent().append('<br />
                            <div class="col-md-4 alert alert-success" role="alert">
                              You have successfully created an email rule!
                            </div>')
      $(@).hide()
      $.post "/api/v1/email_rules", { list_id: $(@).attr("href"), destination_folder: $(@).text() }
