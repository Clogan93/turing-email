class @TuringEmailAppKeyboardHandler
  constructor: (@app) ->
    @handlers =
      "keydown":
        "up": (event) => @moveSelectionUp(event)
        "down": (event) => @moveSelectionDown(event)
        
        "k": (event) => @moveSelectionUp(event)
        "j": (event) => @moveSelectionDown(event)
        
        "c": (event) => @showCompose(event)

        "r": (event) => @showReply(event)
        
        "e": (event) => @archiveEmail(event)
        "y": (event) => @archiveEmail(event)

        "v": (event) => @showMoveToFolderMenu(event)
    
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
    
  archiveEmail: (event) ->
    event.preventDefault()
    
    @app.archiveClicked()

  showMoveToFolderMenu: (event) ->
    event.preventDefault()
    
    @app.views.toolbarView.showMoveToFolderMenu()
