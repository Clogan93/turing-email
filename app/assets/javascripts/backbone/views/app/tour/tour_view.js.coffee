TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.TourView extends Backbone.View
  template: JST["backbone/templates/app/tour/tour"]

  render: ->
    @$el.html(@template())

    $("body").powerTour tours: [
      {
        trigger: ""
        startWith: 0
        easyCancel: true
        escKeyCancel: true
        scrollHorizontal: false
        keyboardNavigation: true
        loopTour: false
        onStartTour: (ui) ->

        onEndTour: ->
          
          # animate back to the top
          $("html, body").animate
            scrollTop: 0
          , 1000, "swing"
          return

        #$('html, body').animate({scrollLeft:0}, 1000, 'swing');  
        onProgress: (ui) ->

        steps: [
          {
            hookTo: "" #not needed
            content: @$el.find(".welcome-tour-step-1")
            width: 400
            position: "sc"
            offsetY: 0
            offsetX: 0
            fxIn: "fadeIn"
            fxOut: "bounceOutUp"
            showStepDelay: 500
            center: "step"
            scrollSpeed: 400
            scrollEasing: "swing"
            scrollDelay: 0
            timer: "00:00"
            highlight: true
            keepHighlighted: true
            onShowStep: (ui) ->

            onHideStep: (ui) ->
          }
          {
            hookTo: "" #not needed
            content: @$el.find(".welcome-tour-step-2")
            width: 400
            position: "sc"
            offsetY: 0
            offsetX: 0
            fxIn: "fadeIn"
            fxOut: "bounceOutLeft"
            showStepDelay: 1000
            center: "step"
            scrollSpeed: 400
            scrollEasing: "swing"
            scrollDelay: 0
            timer: "00:00"
            highlight: true
            keepHighlighted: true
            onShowStep: (ui) ->

            onHideStep: (ui) ->
          }
          {
            hookTo: "" #not needed
            content: @$el.find(".welcome-tour-step-3")
            width: 400
            position: "sc"
            offsetY: 0
            offsetX: 0
            fxIn: "fadeIn"
            fxOut: "bounceOutRight"
            showStepDelay: 1000
            center: "step"
            scrollSpeed: 400
            scrollEasing: "swing"
            scrollDelay: 0
            timer: "00:00"
            highlight: true
            keepHighlighted: true
            onShowStep: (ui) ->

            onHideStep: (ui) ->
          }
        ]
        stepDefaults: [
          width: 500
          position: "tr"
          offsetY: 0
          offsetX: 0
          fxIn: ""
          fxOut: ""
          showStepDelay: 0
          center: "step"
          scrollSpeed: 200
          scrollEasing: "swing"
          scrollDelay: 0
          timer: "00:00"
          highlight: true
          keepHighlighted: false
          onShowStep: ->

          onHideStep: ->
        ]
      }
    ]
    $('body').powerTour('run',0)

    return this
