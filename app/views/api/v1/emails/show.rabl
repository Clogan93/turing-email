object @email

node(:id) do |email|
  email.uid
end

attributes :auto_filed
attributes :uid, :message_id, :list_id
attributes :seen, :snippet, :date

attributes :from_name, :from_address
attributes :sender_name, :sender_address
attributes :reply_to_name, :reply_to_address

attributes :tos, :ccs, :bccs
attributes :subject
attributes :html_part, :text_part, :body_text
