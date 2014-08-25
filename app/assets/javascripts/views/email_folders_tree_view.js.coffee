window.EmailFoldersTreeView = Backbone.View.extend(
    template: _.template("""
    <%= l_html %>
    """)

    render: ->
        @$el.empty()

        console.log @collection

        #Re-order the collection elements.
        tree = this.decompose_collection(@collection)

        label_html = this.compose_label_html(tree)

        #Render the collection elements
        @$el.html @template({l_html: label_html})
        this

    append_list_data: (tree) ->
        label_html = "<ul>"
        for key, value of tree
            label_has_children = Object.keys(value).length > 3
            if value.num_unread_threads == 0
                badge_string = ""
            else
                badge_string = value.num_unread_threads.toString()
            if value.label_type != "system"
                if label_has_children
                    label_html += "<li><span class='bullet_span'>‣ </span><a href='#label#" + value.label_id + "'>" + key + " <span class='badge'>" + badge_string + "</span></a>"
                else
                    label_html += "<li class='label_without_children'><a href='#label#" + value.label_id + "'>" + key + " <span class='badge'>" + badge_string + "</span></a>"
            delete value.label_type
            delete value.label_id
            delete value.num_unread_threads
            if label_has_children
                label_html += this.append_list_data(value)
            label_html += "</li>"
        label_html += "</ul>"
        return label_html

    compose_label_html: (tree) ->
        label_html = this.append_list_data(tree, label_html)
        return label_html

    decompose_collection: (collection) ->
        label_json = collection.toJSON()
        tree = {}

        for label in label_json
            parts = label.gmail_label.name.split("/")
            parent = tree

            for part in parts
                if not parent[part]?
                    parent[part] = {}
                    parent[part]["label_id"] = label.gmail_label.label_id
                    parent[part]["num_unread_threads"] = label.gmail_label.num_unread_threads
                    parent[part]["label_type"] = label.gmail_label.label_type
                parent = parent[part]
        return tree

)