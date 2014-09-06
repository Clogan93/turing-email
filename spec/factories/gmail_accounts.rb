# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gmail_account do
    after(:create) do |gmail_account|
      if gmail_account.google_o_auth2_token.nil?
        gmail_account.google_o_auth2_token = FactoryGirl.create(:google_o_auth2_token, :google_api => gmail_account)
      end
    end

    user

    sequence(:google_id) { |n| "#{n}" }
    sequence(:email) { |n| "email#{n}@gmail.com" }
    verified_email true

    last_history_id_synced nil
  end
end
