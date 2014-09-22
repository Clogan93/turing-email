require 'rails_helper'

describe ApplicationHelper, :type => :helper do
  describe '#page_title' do
    it 'returns the default title' do
      expect(helper.page_title).to eq($config.service_name)
    end
    
    it 'returns the appended page title' do
      expect(helper.page_title('Test')).to eq("#{$config.service_name} | Test")
    end
  end
end
