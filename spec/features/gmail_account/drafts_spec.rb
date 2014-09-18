require 'rails_helper'

describe 'Gmail drafts support', :type => :feature, :js => true, :link_gmail_account => true do
  let!(:user) {  FactoryGirl.create(:user) }
  let(:gmail_account) { user.gmail_accounts.first }
  
  it 'should create, update, and delete a draft' do
    # create draft
    draft_id, email_draft = gmail_account.create_draft('to@to.com', 'cc@cc.com', 'bcc@bcc.com',
                                                       'subject', 'body')
    
    draft_ids = gmail_account.get_draft_ids()
    expect(draft_ids.values.include?(draft_id)).to be(true)
    
    expect(email_draft.email_recipients.to.first.person.email_address).to eq('to@to.com')
    expect(email_draft.email_recipients.cc.first.person.email_address).to eq('cc@cc.com')
    expect(email_draft.email_recipients.bcc.first.person.email_address).to eq('bcc@bcc.com')
    expect(email_draft.subject).to eq('subject')
    expect(email_draft.text_part).to eq('body')

    # update draft
    draft_id, email_draft = gmail_account.update_draft(draft_id, 'to2@to.com', nil, nil, 'subject2', 'body2')

    draft_ids = gmail_account.get_draft_ids()
    expect(draft_ids.values.include?(draft_id)).to be(true)

    expect(email_draft.email_recipients.to.first.person.email_address).to eq('to2@to.com')
    expect(email_draft.email_recipients.cc.count).to eq(0)
    expect(email_draft.email_recipients.bcc.count).to eq(0)
    expect(email_draft.subject).to eq('subject2')
    expect(email_draft.text_part).to eq('body2')
    
    # delete draft
    gmail_account.delete_draft(draft_id)

    draft_ids = gmail_account.get_draft_ids()
    expect(draft_ids.values.include?(draft_id)).to be(false)
  end
  
  it 'should send a draft' do
    # create draft
    draft_id, email_draft = gmail_account.create_draft('test@turinginc.com', nil, nil,
                                                       'test', 'body')
    expect(email_draft.email_recipients.to.first.person.email_address).to eq('test@turinginc.com')
    expect(email_draft.subject).to eq('test')
    expect(email_draft.text_part).to eq('body')

    # send draft
    email = gmail_account.send_draft(draft_id)
    expect(email.email_recipients.to.first.person.email_address).to eq('test@turinginc.com')
    expect(email.subject).to eq('test')
    expect(email.text_part).to eq('body')
  end
end
