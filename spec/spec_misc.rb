module SpecMisc
  TINY_LIST_SIZE = 3
  SMALL_LIST_SIZE = 5
  MEDIUM_LIST_SIZE = 10
  LARGE_LIST_SIZE = 20
  
  GMAIL_TEST_EMAIL = 'turingemailtest1@gmail.com'
  GMAIL_TEST_PASSWORD = 'wZLcsS3XZUN3u2wy'

  def create_email_thread_emails(email_threads, email_folder = nil)
    emails = []

    email_threads.each do |email_thread|
      emails += FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE,
                                        :email_thread => email_thread)

      create_email_folder_mappings(email_thread.emails, email_folder)
    end

    return emails
  end
  
  def create_email_folder_mappings(emails, email_folder = nil)
    emails.each do |email|
      properties = { :email => email }
      properties[:email_folder] = email_folder if email_folder
      FactoryGirl.create(:email_folder_mapping, properties)
    end
  end

  def spec_validate_attributes(expected_attributes, model, model_rendered, expected_attributes_to_skip = [])
    expected_attributes = expected_attributes.sort

    keys = model_rendered.keys.sort!
    expect(keys).to eq(expected_attributes)

    model_rendered.each do |key, value|
      next if expected_attributes.include?(key)

      if model.respond_to?(key)
        expect(value).to eq(model.send(key))
      else
        expect(value).to eq(model[key])
      end
    end
  end

  def validate_email_thread(email_thread, email_thread_rendered)
    expected_attributes = %w(uid emails)
    expected_attributes_to_skip = %w(emails)
    spec_validate_attributes(expected_attributes, email_thread, email_thread_rendered, expected_attributes_to_skip)

    expected_attributes = %w(auto_filed
                             uid message_id list_id
                             seen snippet date
                             from_name from_address
                             sender_name sender_address
                             reply_to_name reply_to_address
                             tos ccs bccs
                             subject
                             html_part text_part body_text)

    email_thread.emails.zip(email_thread_rendered['emails']).each do |email, email_rendered|
      spec_validate_attributes(expected_attributes, email, email_rendered)
    end
  end

  def validate_gmail_label(gmail_label, gmail_label_rendered)
    expected_attributes = %w(label_id name
                             message_list_visibility label_list_visibility
                             label_type
                             num_threads num_unread_threads)
    spec_validate_attributes(expected_attributes, gmail_label, gmail_label_rendered)
  end
  
  def validate_ip_info(ip_info, ip_info_rendered)
    expected_attributes = %w(ip
                             country_code country_name
                             region_code region_name
                             city zipcode
                             latitude longitude
                             metro_code area_code)
    spec_validate_attributes(expected_attributes, ip_info, ip_info_rendered)
  end

  def validate_email_rule(email_rule, email_rule_rendered)
    expected_attributes = %w(uid from_address to_address subject list_id destination_folder_name)
    spec_validate_attributes(expected_attributes, email_rule, email_rule_rendered)
  end

  def validate_genie_rule(genie_rule, genie_rule_rendered)
    expected_attributes = %w(uid from_address to_address subject list_id)
    spec_validate_attributes(expected_attributes, genie_rule, genie_rule_rendered)
  end

  def verify_models_expected(models_expected, models_rendered, key)
    expect(models_rendered.length).to eq(models_expected.length)

    model_keys_rendered = []

    models_rendered.each do |model_rendered|
      model_keys_rendered << model_rendered[key]
    end

    models_expected.each do |model_expected|
      expect(model_keys_rendered.include?(model_expected.send(key))).to eq(true)
    end
  end

  def verify_models_unexpected(models_unexpected, models_rendered, key)
    model_keys_rendered = []

    models_rendered.each do |model_rendered|
      model_keys_rendered << model_rendered[key]
    end

    models_unexpected.each do |model_unexpected|
      expect(model_keys_rendered.include?(model_unexpected.send(key))).to eq(false)
    end
  end
  
  def verify_email(email, email_expected)
    email_expected.each { |k, v| expect(email.send(k)).to eq(v) }
  end
  
  def verify_emails_in_gmail_label(gmail_account, label_id, emails_expected)
    label = gmail_account.gmail_labels.find_by_label_id(label_id)
    emails = label.emails.order(:date)
    expect(emails.count).to eq(emails_expected.length)

    emails.zip(emails_expected).each do |email, email_expected|
      verify_email(email, email_expected)
    end
  end

  def capybara_signin_user(user)
    visit '/signin'

    fill_in('Email', :with => user.email)
    fill_in('Password', :with => user.password)
    click_button('Login')

    expect(page).to have_link('Signout')
  end
  
  def capybara_link_gmail(user,
                          gmail_email = SpecMisc::GMAIL_TEST_EMAIL,
                          gmail_passowrd = SpecMisc::GMAIL_TEST_PASSWORD)
    visit '/'
    click_link 'Link Gmail Account'

    if !has_field?('Email')
      sleep(2)
      click_button('Accept')
      expect(page).to have_content(I18n.t('gmail.authenticated'))  
    else
      fill_in('Email', :with => gmail_email)
      fill_in('Password', :with => gmail_passowrd)
      click_button('Sign in')
      
      sleep(2)
      click_button('Accept')
      expect(page).to have_content(I18n.t('gmail.authenticated'))
    end
  end
end
