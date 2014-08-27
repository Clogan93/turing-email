class TuringEmailApp.Collections.EmailFoldersCollection extends Backbone.Collection
  model: TuringEmailApp.Models.EmailFolder
  url: '/api/v1/email_folders'
