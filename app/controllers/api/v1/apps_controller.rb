class Api::V1::AppsController < ApiController
  before_action { signed_in_user(true) }

  before_action :correct_user, :except => [:test, :stats, :create, :index, :install, :uninstall]
  before_action :with_app, :only => [:install, :uninstall]

  swagger_controller :apps, 'Apps Controller'

  swagger_api :test do
    summary 'Test app.'

    param :form, :email_thread, :string, false, 'Email Thread'
    
    response :ok
  end
  
  def test
    email_thread = params[:email_thread]
    if email_thread
      emails = email_thread[:emails]
      
      html = "<html><body>HIHIHI!!!!<br />#{emails[(emails.length - 1).to_s]["snippet"]}</body></html>"
    else
      email = params[:email]
      
      html = "<html><body>HIHIHI!!!!<br />#{email["snippet"]}</body></html>"
    end
    
    render :html => html.html_safe
  end

  swagger_api :stats do
    summary 'Stats app.'

    param :form, :email_thread, :string, false, 'Email Thread'

    response :ok
  end

  def stats
    email_thread = params[:email_thread]
    emails = email_thread[:emails]

    html = "<div><strong>Email Thread Stats</strong></div>"
    html += "<div>Num messages: " + email_thread[:num_messages].to_s + "</div>"

    #Word count
    email_thread_word_count = 0
    emails.each do |index, email|
      if email["text_part"]
        email_thread_word_count += email["text_part"].split(" ").length
      end
    end

    html += "<div>Word count: " + email_thread_word_count.to_s + "</div>"

    #Num addresses:
    addresses = []
    emails.each do |index, email|
      addresses.push email["from_address"]
      tos = email["tos"].split(",")
      if email["ccs"]
        ccs = email["ccs"].split(",")
        ccs.each do |cc|
          addresses.push cc
        end
      end
      if email["bccs"]
        bccs = email["bccs"].split(",")
        bccs.each do |bcc|
          addresses.push bcc
        end
      end
    end

    html += "<div>Num addresses: " + addresses.uniq.length.to_s + "</div>"
    
    #Most common word
    words = []
    emails.each do |index, email|
      if email["text_part"]
        text_part = email["text_part"].gsub(/[^0-9a-z ]/i, '')
        words += text_part.split(" ")
      end
    end
    if words.length > 0
      most_common_word = most_common_value(words)
      html += "<div>Most common word: " + most_common_word.to_s + "</div>"
    end

    #Duration
    if emails.length > 1
      log_console "EMAILSYO4"
      first_email_date = Time.parse(emails["0"]["date"])
      log_console first_email_date
      last_email = emails[(emails.length - 1).to_s]
      last_email_date = Time.parse(last_email["date"])
      log_console last_email_date
      num_hours = ((last_email_date - first_email_date) / 1.hour).round
      html += "<div>Duration: " + num_hours.to_s + " hours</div>"
    end

    render :html => html.html_safe
  end

  swagger_api :create do
    summary 'Create an app.'

    param :form, :name, :string, false, 'Name'
    param :form, :description, :string, false, 'Description'
    param :form, :app_type, :string, false, 'App Type'
    param :form, :callback_url, :string, false, 'Callback URL'

    response :ok
  end

  def create
    name = params[:name].blank? ? nil : params[:name]
    description = params[:description].blank? ? nil : params[:description]
    app_type = params[:app_type].blank? ? nil : params[:app_type]
    callback_url = params[:callback_url].blank? ? nil : params[:callback_url]

    begin
      App.find_or_create_by!(:user => current_user,
                             :name => name,
                             :description => description,
                             :app_type => app_type,
                             :callback_url => callback_url)
    rescue ActiveRecord::RecordNotUnique
    end

    render :json => {}
  end

  swagger_api :index do
    summary 'Return existing apps.'

    response :ok
  end

  def index
    @apps = App.all
  end

  swagger_api :install do
    summary 'Installs the app.'

    param :path, :app_uid, :string, :required, 'App UID'

    response :ok
  end

  def install
    current_user.with_lock do
      installed_app = InstalledApp.find_or_create_by!(:user => current_user, :app => @app)
      
      installed_panel_app = InstalledPanelApp.new()
      installed_panel_app.installed_app = installed_app
      installed_panel_app.save!
      
      installed_app.installed_app_subclass = installed_panel_app
      installed_app.save!
    end

    render :json => {}
  end

  swagger_api :uninstall do
    summary 'Uninstalls the app.'

    param :path, :app_uid, :string, :required, 'App UID'

    response :ok
  end

  def uninstall
    installed_app = InstalledApp.find_by(:app => @app, :user => current_user)
    installed_app.destroy! if installed_app

    render :json => {}
  end

  swagger_api :destroy do
    summary 'Delete app.'

    param :form, :app_uid, :string, :required, 'App UID'

    response :ok
  end

  def destroy
    @app.destroy!

    render :json => {}
  end

  private

  # Before filters

  def correct_user
    @app = App.find_by(:user => current_user,
                       :uid => params[:app_uid])

    if @app.nil?
      render :status => $config.http_errors[:app_not_found][:status_code],
             :json => $config.http_errors[:app_not_found][:description]
      return
    end
  end
  
  def with_app
    @app = App.find_by_uid(params[:app_uid])

    if @app.nil?
      render :status => $config.http_errors[:app_not_found][:status_code],
             :json => $config.http_errors[:app_not_found][:description]
      return
    end
  end
end
