# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	$("#compose_form").submit ->
	    url = "/send_emails"
	    $.ajax
	        type: "POST"
	        url: url
	        data: $("#compose_form").serialize() # serializes the form's elements.
	        success: (data) ->
	            alert data # show response from the php script.
	            return

	    false # avoid to execute the actual submit of the form.
