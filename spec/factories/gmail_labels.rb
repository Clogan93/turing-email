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
end
