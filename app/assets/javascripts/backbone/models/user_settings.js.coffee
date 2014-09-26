class TuringEmailApp.Models.UserSettings extends Backbone.Model
  url: "/api/v1/user_configurations"

  validation:
    genie_enabled:
      required: true
  
    split_pane_mode:
      required: true
