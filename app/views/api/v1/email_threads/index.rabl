collection @email_threads

node(:next_page_token) do
  @next_page_token
end

extends('api/v1/email_threads/show')
