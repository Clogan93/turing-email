class @TuringEmailAppKeyboardHandler
  constructor: (@app) ->
    @handlers =
      "keydown":
        "up": (event) => @moveSelectionUp(event)
        "down": (event) => @moveSelectionDown(event)
        
        "K": (event) => @moveSelectionUp(event)
        "J": (event) => @moveSelectionDown(event)
        
        "C": (event) => @showCompose(event)

        "R": (event) => @showReply(event)
        "F": (event) => @showForward(event)
        
        "E": (event) => @archiveEmail(event)
        "Y": (event) => @archiveEmail(event)

        "V": (event) => @showMoveToFolderMenu(event)
    
  start: ->
    this.bindKeys()
    
  stop: ->
    this.unbindKeys()

  bindKeys: ->
    for type, typeHandlers of @handlers
      $(document).on(type, null, keys, callback) for keys, callback of typeHandlers

  unbindKeys: ->
    for type, typeHandlers of @handlers
      $(document).off(type, callback) for keys, callback of typeHandlers

  moveSelectionUp: (event) ->
    event.preventDefault()

    @app.views.mainView.emailThreadsListView.moveSelectionUp()

  moveSelectionDown: (event) ->
    event.preventDefault()

    @app.views.mainView.emailThreadsListView.moveSelectionDown()

  showCompose: (event) ->
    event.preventDefault()

    @app.views.composeView.loadEmpty()
    @app.views.composeView.show()

  showReply: (event) ->
    event.preventDefault()

    @app.replyClicked()

  showForward: (event) ->
    event.preventDefault()

    @app.forwardClicked()
    
  archiveEmail: (event) ->
    event.preventDefault()
    
    @app.archiveClicked()

  showMoveToFolderMenu: (event) ->
    event.preventDefault()
    
    @app.views.toolbarView.showMoveToFolderMenu()
