TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.InboxEfficiencyReportView extends Backbone.View
  template: JST["backbone/templates/reports/inbox_efficiency_report"]

  className: "report-view"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    @$el.html(@template(@model.toJSON()))

    report = new Report(@)
    report.setupReportsDropdown()

    return this
