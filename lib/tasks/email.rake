desc "This task is called by the Heroku scheduler add-on"

task :sync_email => :environment do
  GmailAccount.each do |gmail_account|
    begin
      email = Email.new
      email.message_id = email.message_id
      email.user = user
      email.save!
      
      email.from_address = user.from_address
    
      email.tos = email.to.join('; ') if !email.to.blank?
      email.ccs = email.cc.join('; ') if !email.cc.blank?
      email.subject = email.subject.nil? ? '' : email.subject
    
      email.text_part = email.text_part.decoded.force_utf8 if email.text_part
      email.html_part = email.html_part.decoded.force_utf8 if email.html_part
      email.body_text = email.decoded.force_utf8 if !email.multipart? && email.content_type =~ /text/i
    end
  end
end
