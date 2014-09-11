require 'rails_helper'

context 'parse_email_string' do
  it 'should parse email addresses correctly' do
    # no brackets
    expect(parse_email_string('test@turinginc.com')).to eq({ :display_name => nil, :address => 'test@turinginc.com' })

    expect(parse_email_string('hithere test@turinginc.com')).to eq({ :display_name => 'hithere',
                                                                      :address => 'test@turinginc.com' })
    
    expect(parse_email_string('hi there test@turinginc.com')).to eq({ :display_name => 'hi there',
                                                                      :address => 'test@turinginc.com' })
    
    # brackets
    expect(parse_email_string('Test Hello There <test@turinginc.com>')).to eq({ :display_name => 'Test Hello There',
                                                                                :address => 'test@turinginc.com' })
    
    expect(parse_email_string('Test Hello There<test@turinginc.com>')).to eq({ :display_name => 'Test Hello There',
                                                                               :address => 'test@turinginc.com' })
    
    # missing bracket
    expect(parse_email_string('Hi <test@turinginc.com')).to eq({ :display_name => 'Hi',
                                                                 :address => 'test@turinginc.com' })

    expect(parse_email_string('Hi<test@turinginc.com')).to eq({ :display_name => 'Hi',
                                                                 :address => 'test@turinginc.com' })
  end
end

context 'parse_email_list_address' do
  it 'should parse email list addresses correctly' do
    # no @
    expect(parse_email_list_address('sales.turinginc.com')).to eq({ :name => 'sales', :domain => 'turinginc.com' })
    
    # has @
    expect(parse_email_list_address('sales@turinginc.com')).to eq({ :name => 'sales', :domain => 'turinginc.com' })
  end
end

context 'parse_email_address_field' do
  
end

context 'cleanse_email' do
  it 'should cleanse emails' do
    expect(cleanse_email('Sales@turinGinc.com')).to eq('sales@turinginc.com')
    expect(cleanse_email('salEs@turinGinC.com ')).to eq('sales@turinginc.com')
    expect(cleanse_email(' sales@turInginc.COM')).to eq('sales@turinginc.com')
    expect(cleanse_email('    sales@Turinginc.com ')).to eq('sales@turinginc.com')
  end
end

