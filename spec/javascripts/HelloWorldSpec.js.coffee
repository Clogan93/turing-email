helloWorld = ->
    "Hello world!"

describe "KeyboardShortcutHandler", ->
    ksh = undefined
    beforeEach ->
        ksh = new KeyboardShortcutHandler
        ksh.keyboard_shortcuts_are_turned_on = true
        return

    it "should trigger a compose modal upon pressing c", ->
        ksh.bind_compose()
        return

    return

describe "Hello world", ->
    it "says hello", ->
        expect(helloWorld()).toEqual "Hello world!"
        return

    return
