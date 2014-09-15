
class @KeyboardShortcutHandler

  constructor: ->
    this.keyboard_shortcuts_are_turned_on = false
    @current_email_thread_index = 1

  start: ->
    if this.keyboard_shortcuts_are_turned_on
      this.bind_keys()

  bind_keys: ->
    this.bind_compose()

    #Unimplemented
    this.bind_compose_in_a_new_tab()
    this.bind_search()
    this.bind_move_to_newer_conversation()
    this.bind_move_to_older_conversation()
    this.bind_newer_message()
    this.bind_previous_message()
    this.bind_go_to_next_inbox_section()
    this.bind_go_to_previous_inbox_section()
    this.bind_open()
    this.bind_return_to_conversation_list()
    this.bind_archive()
    this.bind_mute()
    this.bind_select_conversation()
    this.bind_star_a_message_or_conversation()
    this.bind_mark_as_important()
    this.bind_mark_as_unimportant()
    this.bind_report_spam()
    this.bind_reply()
    this.bind_reply_all()
    this.bind_forward()
    this.bind_escape_from_input_field()
    this.bind_save_draft()
    this.bind_delete()
    this.bind_label()
    this.bind_move_to()
    this.bind_mark_as_read()
    this.bind_mark_as_unread()
    this.bind_removes_from_current_view_and_previous()
    this.bind_removes_from_current_view_and_next()
    this.bind_archive_and_previous()
    this.bind_archive_and_next()
    this.bind_undo()
    this.bind_update_current_conversation()
    this.bind_move_cursor_to_chat_search()
    this.bind_remove_from_current_view()
    this.bind_show_more_actions()
    this.bind_moves_cursor_to_the_first_button_in_yourgmail_toolbar()
    this.bind_opens_options_in_chat()
    this.bind_move_up_a_contact()
    this.bind_move_down_a_contact()
    this.bind_return_to_contact_list_view()
    this.bind_remove_from_current_group()
    this.bind_select_contact()
    this.bind_escape_from_input_field()
    this.bind_group_membership()
    this.bind_undo()

  #Allows you to compose a new message. Shift + c allows you to compose a message in a new window.
  bind_compose: ->
    $(document).bind "keydown", "c", ->
      $("#compose_button").click()
      return

  #Opens or moves your cursor to a more recent conversation. You can hit Enter to expand a conversation.
  bind_move_to_newer_conversation: ->
    $(document).bind "keydown", "k", =>
      $("#email_table_body tr:nth-child(" + @current_email_thread_index + ")").removeClass("email_thread_highlight")
      if @current_email_thread_index > 1
        @current_email_thread_index -= 1
      $("#email_table_body tr:nth-child(" + @current_email_thread_index + ")").addClass("email_thread_highlight")
      return

  #Opens or moves your cursor to the next oldest conversation. You can hit Enter to expand a conversation.
  bind_move_to_older_conversation: ->
    $(document).bind "keydown", "j", =>
      $("#email_table_body tr:nth-child(" + @current_email_thread_index + ")").removeClass("email_thread_highlight")
      if @current_email_thread_index < 50
        @current_email_thread_index += 1
      $("#email_table_body tr:nth-child(" + @current_email_thread_index + ")").addClass("email_thread_highlight")
      return

  #Moves the conversation from the inbox to a different label, Spam or Trash.
  bind_move_to: ->
    $(document).bind "keydown", "v", ->
      $("#moveToFolderDropdownMenu").click()

  #Automatically checks and selects a conversation so that you can archive, apply a label, or choose an action from the drop-down menu to apply to that conversation.
  bind_select_conversation: ->
    $(document).bind "keydown", "x", =>
      $("#email_table_body tr:nth-child(" + @current_email_thread_index + ") .icheckbox_square-green").toggleClass("checked")

  #Automatically removes the message or conversation from your current view.
  bind_remove_from_current_view: ->
    $(document).bind "keydown", "y", ->
      $("i.fa-archive").parent().click()

  #Archive your conversation from any view.
  bind_archive: ->
    $(document).bind "keydown", "e", ->
      $("i.fa-archive").parent().click()

  #Moves the conversation to Trash.
  bind_delete: ->
    $(document).bind "keydown", "#", ->
      $("i.fa-trash-o").parent().click()

  #Opens your conversation. Also expands or collapses a message if you are in 'Conversation View.'
  bind_open: ->
    $(document).bind "keydown", "o", =>
      $("#email_table_body tr:nth-child(" + @current_email_thread_index + ") .mail-subject a")[0].click()

  #Replies to the message sender. Shift + r allows you to reply to a message in a new window. (Only applicable in 'Conversation View.')
  bind_reply: ->
    $(document).bind "keydown", "r", =>
      emailThreadIndex = @current_email_thread_index - 1
      last_email_in_thread = TuringEmailApp.emailThreads.models[emailThreadIndex].get("emails")[0]

      if last_email_in_thread.reply_to_address?
        $("#compose_form #to_input").val(last_email_in_thread.reply_to_address)
      else
        $("#compose_form #to_input").val(last_email_in_thread.from_address)

      $("#compose_form #subject_input").val("Re: " + last_email_in_thread.subject)
      $("#compose_form #compose_email_body").val("\n\n\n\n\n" + last_email_in_thread.body_text)

      $("#composeModal").modal "show"

  #Refreshes your page and returns you to the inbox, or list of conversations.
  bind_return_to_conversation_list: ->
    $(document).bind "keydown", "u", ->
      window.location.href = "http://localhost:4000/inbox";
      return

  #Opens a compose window in a new tab.
  bind_compose_in_a_new_tab: ->
    $(document).bind "keydown", "d", ->
      return

  #Puts your cursor in the search box.
  bind_search: ->
    $(document).bind "keydown", "/", ->
      return

  #In 'Conversation view', moves your cursor to the newer message. You can hitEnter to expand or collapse a message.
  bind_newer_message: ->
    $(document).bind "keydown", "n", ->
      return

  #In 'Conversation view', moves your cursor to the older message. You can hitEnter to expand or collapse a message.
  bind_previous_message: ->
    $(document).bind "keydown", "p", ->
      return

  #If you use an inbox style with tabs or sections, you can quickly navigate to the next section.
  bind_go_to_next_inbox_section: ->
    $(document).bind "keydown", "`", ->
      return

  #If you use an inbox style with tabs or sections, you can quickly navigate to the previous section.
  bind_go_to_previous_inbox_section: ->
    $(document).bind "keydown", "~", ->
      return

  #Archives the conversation, and all future messages skip the Inbox unless sent or cc'd directly to you. Learn more.
  bind_mute: ->
    $(document).bind "keydown", "m", ->
      return

  #Adds or removes a star to a message or conversation. Stars allow you to give a message or conversation a special status.
  bind_star_a_message_or_conversation: ->
    $(document).bind "keydown", "s", ->
      return

  #Helps Gmail learn what's important to you by marking misclassified messages. (Specific to Priority Inbox)
  bind_mark_as_important: ->
    $(document).bind "keydown", "+", ->
      return

  #Helps Gmail learn what's not important to you by marking misclassified messages. (Specific to Priority Inbox)
  bind_mark_as_unimportant: ->
    $(document).bind "keydown", "-", ->
      return

  #Marks a message as spam and removes it from your conversation list.
  bind_report_spam: ->
    $(document).bind "keydown", "!", ->
      return

  #Replies to all message recipients. Shift + a allows you to reply to all message recipients in a new window. (Only applicable in 'Conversation View.')
  bind_reply_all: ->
    $(document).bind "keydown", "a", ->
      return

  #Forwards a message. Shift + f allows you to forward a message in a new window. (Only applicable in 'Conversation View.')
  bind_forward: ->
    $(document).bind "keydown", "f", ->
      return

  #Removes the cursor from your current input field.
  bind_escape_from_input_field: ->
    $(document).bind "keydown", "Esc", ->
      return

  #Saves the current text as a draft when composing a message. Hold the Ctrl/⌘key while pressing s and make sure your cursor is in one of the text fields -- either the composition pane, or any of the To, CC, BCC, or Subject fields -- when using this shortcut.
  bind_save_draft: ->
    $(document).bind "keydown", "Ctrl + s", ->
      return

  #Opens the Labels menu to label a conversation.
  bind_label: ->
    $(document).bind "keydown", "l", ->
      return

  #Marks your message as 'read' and skip to a newer message.
  bind_mark_as_read: ->
    $(document).bind "keydown", "Shift + i", ->
      return

  #Marks your message as 'unread' so you can go back to it later.
  bind_mark_as_unread: ->
    $(document).bind "keydown", "Shift + u", ->
      return

  #Removes the current view's label from your conversation and moves to the older one.
  bind_removes_from_current_view_and_previous: ->
    $(document).bind "keydown", "[", ->
      return

  #Removes the current view's label from your conversation and moves to the newer one.
  bind_removes_from_current_view_and_next: ->
    $(document).bind "keydown", "]", ->
      return

  #Archives the current conversation and moves to the older one.
  bind_archive_and_previous: ->
    $(document).bind "keydown", "{", ->
      return

  #Archives the current conversation and moves to the next one.
  bind_archive_and_next: ->
    $(document).bind "keydown", "}", ->
      return

  #Undoes your previous action, if possible (works for actions with an 'undo' link).
  bind_undo: ->
    $(document).bind "keydown", "z", ->
      return

  #Updates your current conversation when there are new messages.
  bind_update_current_conversation: ->
    $(document).bind "keydown", "Shift + n", ->
      return

  #Moves your cursor directly to the chat search box.
  bind_move_cursor_to_chat_search: ->
    $(document).bind "keydown", "q", ->
      return

  #Displays the 'More Actions' drop-down menu.
  bind_show_more_actions: ->
    $(document).bind "keydown", ".", ->
      return

  #Displays the 'More Actions' drop-down menu.
  bind_moves_cursor_to_the_first_button_in_yourgmail_toolbar: ->
    $(document).bind "keydown", ",", ->
      return

  #Ctrl/⌘ + Down arrow moves from edit field in your chat window to select the 'Video and more' menu. Next, press Tab to select the emoticon menu.Press Enter to open the selected menu
  bind_opens_options_in_chat: ->
    $(document).bind "keydown", "Ctrl + Down arrow", ->
      return

  #Moves your cursor up in your contact list
  bind_move_up_a_contact: ->
    $(document).bind "keydown", "k", ->
      return

  #Moves your cursor down in your contact list
  bind_move_down_a_contact: ->
    $(document).bind "keydown", "j", ->
      return

  #Refreshes your page and returns you to the contact list.
  bind_return_to_contact_list_view: ->
    $(document).bind "keydown", "u", ->
      return

  #Removes selected contacts from the group currently being displayed.
  bind_remove_from_current_group: ->
    $(document).bind "keydown", "e", ->
      return

  #Checks and selects a contact so that you can change group membership or choose an action from the drop-down menu to apply to the contact.
  bind_select_contact: ->
    $(document).bind "keydown", "x", ->
      return

  #Removes the cursor from the current input
  bind_escape_from_input_field: ->
    $(document).bind "keydown", "Esc", ->
      return

  #Opens the groups button to group contacts
  bind_group_membership: ->
    $(document).bind "keydown", "l", ->
      return

  #Reverses your previous action, if possible (works for actions with an 'undo' link)
  bind_undo: ->
    $(document).bind "keydown", "z", ->
      return

ksh = new KeyboardShortcutHandler
ksh.keyboard_shortcuts_are_turned_on = true
ksh.start()
