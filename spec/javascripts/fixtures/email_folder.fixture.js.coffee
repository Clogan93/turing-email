@fixtures = _.extend(@fixtures or {},
  EmailFolder:
    valid:
      status: "OK"
      version: "1.0"
      response:
        label_id: "INBOX"
        label_list_visibility: "labelShow"
        label_type: "system"
        message_list_visibility: "hide"
        name: "INBOX"
        num_threads: 179
        num_unread_threads: 130
)
return