node(:draft_id) do
  @draft_id
end

node(:email) do
  partial('api/v1/emails/show', object: @email)
end
