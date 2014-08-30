#= require keyboard_shortcuts/keyboard_shortcuts

describe "KeyboardShortcutHandler", ->
    ksh = undefined
    beforeEach ->
        ksh = new KeyboardShortcutHandler
        ksh.keyboard_shortcuts_are_turned_on = true
        return

    it "should trigger a compose modal upon pressing c", ->
        ksh.bind_compose()
        events = $._data(document, "events")
        bound_keys = []
        for keydownEvent in events.keydown
            if keydownEvent.data?
                bound_keys.push(keydownEvent.data.keys)
        expect(bound_keys).toContain("c")
        return

    it "should bind all keys with events", ->
        ksh.bind_keys()
        keys_that_should_be_bound = ["c", "d", "/", "k", "j", "n", "p", "`", "~", "u", "e", "m", "x", "s", "+", "-", "!", "r", "a", "f", "Esc", "#", "l", "v", "[", "]", "{", "}", "z", "q", "y", ".", ",", "k", "j", "u", "e", "x", "Esc", "#", "l", "z", "c"]
        events = $._data(document, "events")
        bound_keys = []
        for keydownEvent in events.keydown
            if keydownEvent.data?
                bound_keys.push(keydownEvent.data.keys)
        for key in keys_that_should_be_bound
            expect(bound_keys).toContain(key)
        return

    return
