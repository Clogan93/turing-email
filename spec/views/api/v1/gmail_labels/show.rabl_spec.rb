require 'rails_helper'

describe 'api/v1/gmail_labels/show', :type => :view do
  it 'should render the Gmail label' do
    gmail_label = assign(:gmail_label, FactoryGirl.create(:gmail_label))

    render

    gmail_label_rendered = JSON.parse(rendered)

    expected_attributes = %w(label_id name
                             message_list_visibility label_list_visibility
                             label_type
                             num_threads num_unread_threads)
    spec_validate_attributes(expected_attributes, gmail_label, gmail_label_rendered)
  end
end
