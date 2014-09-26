class TuringEmailApp.Models.EmailFolder extends Backbone.Model
  validation:
    label_id:
      required: true
  
    label_list_visibility:
      required: true
  
    label_type:
      required: true
  
    message_list_visibility:
      required: true
  
    name:
      required: true
  
    num_threads:
      required: true
  
    num_unread_threads:
      required: true
