# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gmail_label do
    gmail_account

    sequence(:label_id) { |n| "Label ID #{n}" }
    sequence(:name) { |n| "Label Name #{n}" }
    message_list_visibility true
    label_list_visibility true
    label_type 'user'
  end

  factory :gmail_label_inbox, :parent => :gmail_label do
    label_id 'INBOX'
    name 'INBOX'
    label_type 'system'
  end

  factory :gmail_label_sent, :parent => :gmail_label do
    label_id 'SENT'
    name 'SENT'
    label_type 'system'
  end

  factory :gmail_label_trash, :parent => :gmail_label do
    label_id 'TRASH'
    name 'TRASH'
    label_type 'system'
  end
end
