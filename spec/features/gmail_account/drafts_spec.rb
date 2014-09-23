require 'rails_helper'

describe 'Gmail drafts support', :type => :feature, :js => true, :link_gmail_account => true do
  let!(:user) {  FactoryGirl.create(:user) }
  let(:gmail_account) { user.gmail_accounts.first }
  
  it 'should create, update, and delete a draft' do
    # create draft
    email_draft = gmail_account.create_draft('to@to.com', 'cc@cc.com', 'bcc@bcc.com', 'subject', 'body')
    expect(email_draft.draft_id).not_to be(nil)
    
    draft_ids = gmail_account.get_draft_ids()
    expect(draft_ids.values.include?(email_draft.draft_id)).to be(true)
    
    expect(email_draft.email_recipients.to.first.person.email_address).to eq('to@to.com')
    expect(email_draft.email_recipients.cc.first.person.email_address).to eq('cc@cc.com')
    expect(email_draft.email_recipients.bcc.first.person.email_address).to eq('bcc@bcc.com')
    expect(email_draft.subject).to eq('subject')
    expect(email_draft.text_part).to eq('body')

    # update draft
    email_draft = gmail_account.update_draft(email_draft.draft_id, 'to2@to.com', nil, nil, 'subject2', 'body2')
    expect(email_draft.draft_id).not_to be(nil)

    draft_ids = gmail_account.get_draft_ids()
    expect(draft_ids.values.include?(email_draft.draft_id)).to be(true)

    expect(email_draft.email_recipients.to.first.person.email_address).to eq('to2@to.com')
    expect(email_draft.email_recipients.cc.count).to eq(0)
    expect(email_draft.email_recipients.bcc.count).to eq(0)
    expect(email_draft.subject).to eq('subject2')
    expect(email_draft.text_part).to eq('body2')
    
    # delete draft
    gmail_account.delete_draft(email_draft.draft_id)
    expect(gmail_account.emails.find_by_draft_id(email_draft.draft_id)).to be(nil)

    draft_ids = gmail_account.get_draft_ids()
    expect(draft_ids.values.include?(email_draft.draft_id)).to be(false)
  end
  
  it 'should send a draft' do
    # create draft
    email_draft = gmail_account.create_draft(SpecMisc::MAILINATOR_TEST_EMAIL, nil, nil, 'test', 'body')
    expect(email_draft.email_recipients.to.first.person.email_address).to eq(SpecMisc::MAILINATOR_TEST_EMAIL)
    expect(email_draft.subject).to eq('test')
    expect(email_draft.text_part).to eq('body')

    # send draft
    email = gmail_account.send_draft(email_draft.draft_id)
    expect(gmail_account.emails.find_by_draft_id(email_draft.draft_id)).to be(nil)
    expect(email.email_recipients.to.first.person.email_address).to eq(SpecMisc::MAILINATOR_TEST_EMAIL)
    expect(email.subject).to eq('test')
    expect(email.text_part).to eq('body')
  end
end
