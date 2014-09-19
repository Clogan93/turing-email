class TuringEmailApp.Models.ThreadsReport extends Backbone.Model
  url: "/api/v1/email_reports/threads_report"

  average_thread_length:
    required: true

  top_email_threads:
    required: true
