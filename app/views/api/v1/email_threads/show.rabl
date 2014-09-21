object @email_thread

attributes :uid

child(:emails) do |email|
  extends('api/v1/emails/show')
end
