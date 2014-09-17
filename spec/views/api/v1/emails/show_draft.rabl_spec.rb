require 'rails_helper'

describe 'api/v1/emails/show_draft', :type => :view do
  it 'should render the email draft' do
    draft_id = assign(:draft_id, 'draft_id')
    email = assign(:email, FactoryGirl.create(:email))
    render
    result = JSON.parse(rendered)
    
    draft_id_rendered = result['draft_id']
    email_rendered = result['email']

    expect(draft_id_rendered).to eq(draft_id)
    validate_email(email, email_rendered)
  end
end
