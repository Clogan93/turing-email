describe "EmailFolders collection", ->
    beforeEach ->
        @email_folder1 = new Backbone.Model(
            id: 1
            title: "EmailFolder 1"
        )
        @email_folder2 = new Backbone.Model(
            id: 2
            title: "EmailFolder 2"
        )
        @email_folder3 = new Backbone.Model(
            id: 3
            title: "EmailFolder 3"
        )
        @email_folder4 = new Backbone.Model(
            id: 4
            title: "EmailFolder 4"
        )
        @email_folders = new TuringEmailApp.Collections.EmailFoldersCollection()
        @email_folder_stub = sinon.stub(window, "EmailFolder")
        return

    afterEach ->
        @email_folder_stub.restore()
        return

    return
