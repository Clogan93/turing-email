class TuringEmailApp.Models.GeoReport extends Backbone.Model
  url: "/api/v1/email_reports/ip_stats"

  ip_stats:
    required: true
