require 'rails_helper'

describe 'Gmail labels support', :type => :feature, :js => true, :link_gmail_account => true do
  let!(:user) {  FactoryGirl.create(:user) }
  
  it 'sync the labels' do
    gmail_account = user.gmail_accounts.first
    gmail_account.sync_labels()
    
    label_names = gmail_account.gmail_labels.pluck(:name)
    expect(label_names).to include('Stanford')
    expect(label_names).to include('Stanford/clubs')
    expect(label_names).to include('HLS')
    expect(label_names).to include('HLS/classes')

    # resync to make sure there are issues with duplicates
    gmail_account.sync_labels()
    expect(label_names).to include('Stanford')
    expect(label_names).to include('Stanford/clubs')
    expect(label_names).to include('HLS')
    expect(label_names).to include('HLS/classes')
  end
end
