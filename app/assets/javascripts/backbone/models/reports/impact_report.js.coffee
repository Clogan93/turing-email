class TuringEmailApp.Models.ImpactReport extends Backbone.Model
  url: "/api/v1/email_reports/impact_report"

  validation:
    percent_sent_emails_replied_to:
      required: true
