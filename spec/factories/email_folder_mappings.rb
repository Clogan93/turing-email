# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_folder_mapping do
    before(:create) do |email_folder_mapping|
      if email_folder_mapping.email_folder.nil?
        email_folder_mapping.email_folder = FactoryGirl.create(:gmail_label, :gmail_account => email_folder_mapping.email.email_account)
      end
    end

    email
  end
end
