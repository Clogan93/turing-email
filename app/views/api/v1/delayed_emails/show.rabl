object @delayed_email

attributes :uid, :subject

node(:send_at) do |delayed_email|
  delayed_email.send_at()
end