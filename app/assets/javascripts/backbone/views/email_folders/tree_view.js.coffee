TuringEmailApp.Views.EmailFolders ||= {}

class TuringEmailApp.Views.EmailFolders.TreeView extends Backbone.View
  #template: JST["backbone/templates/email_folders/tree"]
  template: _.template("""
    <%= l_html %>
    """)

  initialize: (options) ->
    @listenTo(@collection, 'add', @render)
    @listenTo(@collection, 'reset', @render)

  render: ->
    @generate_tree()

    label_html = this.compose_label_html(@tree)

    #Render the collection elements
    #@template(tree: @tree)
    @$el.html @template({l_html: label_html})
    return this

  generate_tree: ->
    @tree = {children: {}}
    label_json = @collection.toJSON()

    for emailFolder in @collection.toJSON()
      pathParts = emailFolder.name.split("/")
      parent = @tree

      for part in pathParts
        if not parent.children[part]?
          parent.children[part] = {children: {}}

        parent = parent.children[part]

      parent.label_id = emailFolder.label_id
      parent.num_unread_threads = emailFolder.num_unread_threads
      parent.label_type = emailFolder.label_type

  append_list_data: (tree) ->
    label_html = "<ul>"
    for key, value of tree
      label_has_children = Object.keys(value.children).length > 0

      if value.num_unread_threads == 0
        badge_string = ""
      else
        badge_string = value.num_unread_threads.toString()
      if value.label_type != "system"
        if label_has_children
          if value.num_unread_threads > 0
            label_html += "<li class='contains_unread_emails'><span class='bullet_span'>‣ </span><a class='label_link' href='#folder#" + value.label_id + "'>" + key + " <span class='badge'>" + badge_string + "</span></a>"
          else
            label_html += "<li class='contains_no_unread_emails'><span class='bullet_span'>‣ </span><a class='label_link' href='#folder#" + value.label_id + "'>" + key + " <span class='badge'>" + badge_string + "</span></a>"
        else
          if value.num_unread_threads > 0
            label_html += "<li class='label_without_children contains_unread_emails'><a class='label_link' href='#folder#" + value.label_id + "'>" + key + " <span class='badge'>" + badge_string + "</span></a>"
          else
            label_html += "<li class='label_without_children contains_no_unread_emails'><a class='label_link' href='#folder#" + value.label_id + "'>" + key + " <span class='badge'>" + badge_string + "</span></a>"

      label_html += this.append_list_data(value.children)

      label_html += "</li>"

    label_html += "</ul>"
    return label_html

  compose_label_html: (tree) ->
    label_html = this.append_list_data(tree.children, label_html)
    return label_html
