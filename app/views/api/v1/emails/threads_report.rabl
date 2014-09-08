node(:average_thread_length) { @average_thread_length }

node(:top_email_threads) do
  partial('api/v1/email_threads/index', :object => @top_email_threads)
end
