object @user

attributes :email, :has_genie_report_ran

node(:num_emails) do |user|
  user.emails.count
end
