#= require models/email

describe "Backbone's", ->

    describe "Email model", ->

        describe "when instantiated", ->

            it "should exhibit attributes", ->

                todo = new Email(title: "Rake leaves")
                expect(todo.get("title")).toEqual "Rake leaves"
                return

            return

        return

    describe "User model", ->

        describe "when instantiated", ->

            it "should exhibit attributes", ->

                todo = new User(title: "Rake leaves")
                expect(todo.get("title")).toEqual "Rake leaves"
                return

            return

        return

    describe "EmailFolderHeader model", ->

        describe "when instantiated", ->

            it "should exhibit attributes", ->

                todo = new EmailFolderHeader(title: "Rake leaves")
                expect(todo.get("title")).toEqual "Rake leaves"
                return

            return

        return

    return
