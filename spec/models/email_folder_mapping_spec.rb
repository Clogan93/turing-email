require 'rails_helper'

describe EmailFolderMapping, :type => :model do
  let!(:email) { FactoryGirl.create(:email) }
  let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => email.email_account) }

  context 'validations' do
    it 'should fail to save without an email and email folder' do
      email_folder_mapping = EmailFolderMapping.new
      expect(email_folder_mapping.save).to be(false)
  
      email_folder_mapping.email = email
      expect(email_folder_mapping.save).to be(false)
  
      email_folder_mapping.email_folder = gmail_label
      expect(email_folder_mapping.save).to be(true)
    end
  end
end