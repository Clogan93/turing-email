module SpecMisc
  TINY_LIST_SIZE = 3
  SMALL_LIST_SIZE = 5
  MEDIUM_LIST_SIZE = 10
  LARGE_LIST_SIZE = 20

  def create_email_thread_emails(email_account, email_threads, email_folder = nil)
    emails = []

    email_threads.each do |email_thread|
      emails += FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE,
                                        :user => email_account.user,
                                        :email_account => email_account,
                                        :email_thread => email_thread)

      email_thread.emails.each do |email|
        properties = { :email => email }
        properties[:email_folder] = email_folder if email_folder
        FactoryGirl.create(:email_folder_mapping, properties)
      end
    end

    return emails
  end

  def spec_validate_attributes(expected_attributes, model, model_rendered, expected_attributes_to_skip = [])
    expected_attributes.sort!

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

  def capybara_signin_user(user)
    visit '/signin'

    fill_in('Email', :with => user.email)
    fill_in('Password', :with => user.password)
    click_button('Login')

    expect(page).to have_link('Signout')
  end
end
