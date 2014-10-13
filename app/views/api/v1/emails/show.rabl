object @email

node(:id) do |email|
  "id"
end

attributes :auto_filed
attributes :uid, :draft_id, :message_id, :list_id
attributes :seen, :snippet, :date

attributes :from_name, :from_address
attributes :sender_name, :sender_address
attributes :reply_to_name, :reply_to_address

attributes :tos, :ccs, :bccs
attributes :subject
attributes :html_part, :text_part, :body_text

child(:gmail_labels) do |gmail_label|
  extends('api/v1/gmail_labels/show')
end

child(:imap_folders) do |imap_folder|
  extends('api/v1/imap_folders/show')
end
