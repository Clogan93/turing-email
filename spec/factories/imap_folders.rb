# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :imap_folder do
    association :email_account, :factory => :gmail_account

    sequence(:name) { |n| "Folder Name #{n}" }
  end
end
