require 'rails_helper'

describe EmailRecipient, :type => :model do
  let!(:email) { FactoryGirl.create(:email) }
  let!(:person) { FactoryGirl.create(:person, :email_account => email.email_account) }

  context 'validations' do
    it 'should fail to save without an email, person, and recipient type' do
      email_recipient = EmailRecipient.new
      expect(email_recipient.save).to be(false)

      email_recipient.email = email
      expect(email_recipient.save).to be(false)
  
      email_recipient.person = person
      expect(email_recipient.save).to be(false)
  
      email_recipient.recipient_type = EmailRecipient.recipient_types[:to]
      expect(email_recipient.save).to be(true)
    end
  end
end