class TuringEmailApp.Models.AttachmentsReport extends Backbone.Model
  url: "/api/v1/email_reports/attachments_report"

  average_file_size:
    required: true

  content_type_stats:
    required: true
