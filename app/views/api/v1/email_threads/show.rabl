object @email_thread

attributes :uid

child(:emails) do
  extends('api/v1/emails/show')
end
