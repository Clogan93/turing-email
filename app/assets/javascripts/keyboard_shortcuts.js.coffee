
class KeyboardShortcutHandler

    start: ->
        this.bind_keys()

    bind_keys: ->
        this.bind_compose()

    bind_compose: ->
        $(document).bind "keydown", "c", ->
            $("#compose_button").click()
            return

ksh = new KeyboardShortcutHandler
ksh.start()