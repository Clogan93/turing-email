require 'rails_helper'

describe EmailReference, :type => :model do
  let!(:email) { FactoryGirl.create(:email) }

  context 'validations' do
    it 'should fail to save without an email, references_message_id, and position' do
      email_reference = EmailReference.new
      expect(email_reference.save).to be(false)
  
      email_reference.email = email
      expect(email_reference.save).to be(false)
  
      email_reference.references_message_id = 'foo@bar.com'
      expect(email_reference.save).to be(false)
  
      email_reference.position = 0
      expect(email_reference.save).to be(true)
    end
  end
end