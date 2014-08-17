# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	EmailApp.start()
	return

$ ->
	$("#dialog").dialog(
		autoOpen: false
		height: 300
		width: 350
		modal: true
		buttons: [
			{
				text: "Send"
				click: ->
					$(this).dialog "close"
					return
			}
			{
				text: "Cancel"
				click: ->
					$(this).dialog "close"
					return
			}
		]
	)

	$("#compose_button").click ->
		$("#dialog").dialog "open"
		return
