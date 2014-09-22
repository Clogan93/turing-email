require 'rails_helper'

describe Person, :type => :model do
  context 'validations' do
    let(:email_account) { FactoryGirl.create(:gmail_account) }
    let(:email_address) { 'FOO@bar.com' }
    
    it 'should fail to save without an email_account and email_address' do
      person = Person.new
      expect(person.save).to be(false)
      
      person.email_account = email_account
      expect(person.save).to be(false)

      person.email_address = email_address
      expect(person.save).to be(true)
    end
    
    it 'should cleanse the email address' do
      person = Person.new
      person.email_account = email_account
      person.email_address = email_address
      expect(person.save).to be(true)
      expect(person.email_address).to eq(cleanse_email(email_address))
    end
  end
  
  describe '#destroy' do
    let!(:person) { FactoryGirl.create(:person) }
    let!(:email_recipients) { FactoryGirl.create_list(:email_recipient, SpecMisc::MEDIUM_LIST_SIZE, :person => person) }

    it 'should destroy the associated models' do
      expect(EmailRecipient.where(:person => person).count).to eq(email_recipients.length)

      expect(person.destroy).not_to be(false)

      expect(EmailRecipient.where(:person => person).count).to eq(0)
    end
  end
end