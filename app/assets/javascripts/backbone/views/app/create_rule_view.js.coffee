TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.CreateRuleView extends Backbone.View
  template: JST["backbone/templates/app/create_rule"]

  initialize: (options) ->
    @app = options.app
  
  render: ->
    @$el.html(@template())
    @setupCreateRuleView()
    return this

  setupCreateRuleView: ->
    @$el.find(".create-rule-form").submit => @onSubmit()

  show: (mode) ->
    @mode = mode
    if @mode is "email_rule"
      @$el.find(".create-rule-form .create-email-rule-destination-folder").show()
    else if @mode is "genie_rule"
      @$el.find(".create-rule-form .create-email-rule-destination-folder").hide()

    @$el.find(".email-rule-dropdown a").trigger("click.bs.dropdown")

  hide: ->
    @$el.find(".email-rule-dropdown a").trigger("click.bs.dropdown")

  resetView: ->
    @$el.find(".create-rule-form .create-email-rule-to").val("")
    @$el.find(".create-rule-form .create-email-rule-from").val("")
    @$el.find(".create-rule-form .create-email-rule-subject").val("")
    @$el.find(".create-rule-form .create-email-rule-list").val("")
    @$el.find(".create-rule-form .create-email-rule-destination-folder").val("")
    
  onSubmit: ->
    params = {
      from_address: @$el.find(".create-rule-form .create-email-rule-to").val(),
      to_address: @$el.find(".create-rule-form .create-email-rule-from").val(),
      subject: @$el.find(".create-rule-form .create-email-rule-subject").val(),
      list_id: @$el.find(".create-rule-form .create-email-rule-list").val()
    }
    
    if @mode is "email_rule"
      params["destination_folder_name"] = @$el.find(".create-rule-form .create-email-rule-destination-folder").val()
      $.post "/api/v1/email_rules", params
  
      alertToken = TuringEmailApp.showAlert("You have successfully created an email rule!", "alert-success")
    else if @mode is "genie_rule"
      $.post "/api/v1/genie_rules", params
  
      alertToken = TuringEmailApp.showAlert("You have successfully created a brain rule!", "alert-success")
  
    setTimeout (=>
      TuringEmailApp.removeAlert(alertToken)
    ), 3000
  
    @resetView()
  
    @hide()
  
    return false # avoid to execute the actual submit of the form.
