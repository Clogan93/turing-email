window.EmailFolderView = Backbone.View.extend(    
    template: _.template("""
    <div>This is a test.</div>
    """)

    initialize: ->
        @model.on "change", @render, this
        return

    render: ->
        @$el.html @template(@model.toJSON())
        this
)