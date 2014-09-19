require 'rails_helper'

describe Person, :type => :model do
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