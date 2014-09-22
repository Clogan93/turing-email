require 'rails_helper'

describe EmailInReplyTo, :type => :model do
  let!(:email) { FactoryGirl.create(:email) }

  context 'validations' do
    it 'should fail to save without an email and in_reply_to_message_id' do
      email_in_reply_to = EmailInReplyTo.new
      expect(email_in_reply_to.save).to be(false)
  
      email_in_reply_to.email = email
      expect(email_in_reply_to.save).to be(false)
  
      email_in_reply_to.in_reply_to_message_id = 'foo@bar.com'
      expect(email_in_reply_to.save).to be(true)
    end
  end
end
