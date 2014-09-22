require 'rails_helper'

describe 'Gmail search support', :type => :feature, :js => true, :link_gmail_account => true do
  let!(:user) {  FactoryGirl.create(:user) }
  let!(:gmail_account) { user.gmail_accounts.first }
  
  it 'should return threads that match the query' do
    thread_uids, nextPageToken = gmail_account.search_threads('cc email')
    expect(thread_uids).to eq(['1483e7ae2fe0c68f'])
  end
end