require 'rails_helper'

describe 'api/v1/gmail_labels/index', :type => :view do
  it 'should render the Gmail labels' do
    gmail_labels = assign(:gmail_labels, FactoryGirl.create_list(:gmail_label, 25))

    render

    gmail_labels_rendered = JSON.parse(rendered)

    expected_attributes = %w(label_id name
                             message_list_visibility label_list_visibility
                             label_type
                             num_threads num_unread_threads)

    gmail_labels.zip(gmail_labels_rendered).each do |gmail_label, gmail_label_rendered|
      spec_validate_attributes(expected_attributes, gmail_label, gmail_label_rendered)
    end
  end
end
