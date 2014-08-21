module EmailsHelper
  def get_threads_array_from_emails(emails)
    threads = {}

    emails.each do |email|
      threads[email.thread_id] = [] if threads[email.thread_id].nil?
      threads[email.thread_id].push(email)
    end

    @threads_array = []

    threads.each do |thread_id, emails|
      emails.sort! { |x, y| y.date <=> x.date }
      @threads_array.push(:thread => emails)
    end

    @threads_array.sort! { |x, y| y[:thread].first.date <=> x[:thread].first.date }

    return @threads_array
  end
end
