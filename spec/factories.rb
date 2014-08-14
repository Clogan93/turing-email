FactoryGirl.define do
  factory :user do
    email   'foo@bar.com'
    password 'Foobar!1'
    password_confirmation 'Foobar!1'
  end

  factory :locked_user, :class => User do
    email   'foo@bar.com'
    password 'Foobar!1'
    password_confirmation 'Foobar!1'
    login_attempt_count $config.max_login_attempts
  end

  factory :user_other, :class => User do
    email   'foo2@bar.com'
    password 'Foobar!2'
    password_confirmation 'Foobar!2'
  end
end
