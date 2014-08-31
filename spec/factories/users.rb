# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "foo#{n}@bar.com" }
    password 'Foobar!1'
    password_confirmation 'Foobar!1'
  end

  factory :locked_user, :parent => :user do
    login_attempt_count $config.max_login_attempts
  end
end
