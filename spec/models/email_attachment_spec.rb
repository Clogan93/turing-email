require 'rails_helper'

describe EmailAttachment, :type => :model do
  let!(:email) { FactoryGirl.create(:email) }

  it 'should fail to save without an email and file size' do
    email_attachment = EmailAttachment.new
    expect(email_attachment.save).to be(false)

    email_attachment.email = email
    expect(email_attachment.save).to be(false)

    email_attachment.file_size = 100
    expect(email_attachment.save).to be(true)
  end
end