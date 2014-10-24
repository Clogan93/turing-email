Rails.application.routes.draw do
  root 'static_pages#home'
  get '/mail', to: 'static_pages#mail'
  get '/analytics', to: 'static_pages#analytics'

  resources :sessions, only: [:new, :create, :destroy]

  resources :users, only: [:new, :create]
  match('/reset_password', to: 'users#reset_password', via: ['get', 'post'], as: :reset_password)

  get '/gmail_oauth2_callback', to: 'gmail_accounts#o_auth2_callback'
  delete '/gmail_o_auth2_remove', to: 'gmail_accounts#o_auth2_remove'

  get '/signup',  to: 'users#new'
  get '/signin',  to: 'sessions#new'
  delete '/signout', to: 'sessions#destroy'

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      post '/log', to: 'logs#log'
      
      resources :users, only: [:create]
      get '/users/current', to: 'users#current'
      post '/users/declare_email_bankruptcy', to: 'users#declare_email_bankruptcy'

      get '/user_configurations', to: 'user_configurations#show'
      put '/user_configurations', to: 'user_configurations#update'
      patch '/user_configurations', to: 'user_configurations#update'

      get '/gmail_accounts/get_token', to: 'gmail_accounts#get_token'
      
      resources :sessions, only: [:create]
      delete '/signout', to: 'sessions#destroy'

      post '/email_accounts/send_email', to: 'email_accounts#send_email'
      post '/email_accounts/sync', to: 'email_accounts#sync'
      post '/email_accounts/search_threads', to: 'email_accounts#search_threads'
      
      post '/email_accounts/drafts', to: 'email_accounts#create_draft'
      put '/email_accounts/drafts', to: 'email_accounts#update_draft'
      post '/email_accounts/send_draft', to: 'email_accounts#send_draft'
      post '/email_accounts/delete_draft', to: 'email_accounts#delete_draft'
      
      get '/emails/show/:email_uid', to: 'emails#show'
      post '/emails/set_seen', to: 'emails#set_seen'
      post '/emails/move_to_folder', to: 'emails#move_to_folder'
      post '/emails/apply_gmail_label', to: 'emails#apply_gmail_label'
      post '/emails/remove_from_folder', to: 'emails#remove_from_folder'
      post '/emails/trash', to: 'emails#trash'

      get '/email_threads/show/:email_thread_uid', to: 'email_threads#show'
      get '/email_threads/inbox', to: 'email_threads#inbox'
      get '/email_threads/in_folder', to: 'email_threads#in_folder'
      post '/email_threads/move_to_folder', to: 'email_threads#move_to_folder'
      post '/email_threads/apply_gmail_label', to: 'email_threads#apply_gmail_label'
      post '/email_threads/remove_from_folder', to: 'email_threads#remove_from_folder'
      post '/email_threads/trash', to: 'email_threads#trash'
      
      get '/email_reports/ip_stats_report', to: 'email_reports#ip_stats_report'
      get '/email_reports/volume_report', to: 'email_reports#volume_report'
      get '/email_reports/contacts_report', to: 'email_reports#contacts_report'
      get '/email_reports/attachments_report', to: 'email_reports#attachments_report'
      get '/email_reports/lists_report', to: 'email_reports#lists_report'
      get '/email_reports/threads_report', to: 'email_reports#threads_report'
      get '/email_reports/folders_report', to: 'email_reports#folders_report'
      get '/email_reports/impact_report', to: 'email_reports#impact_report'
      
      resources :email_folders, only: [:index]
      
      resources :genie_rules, only: [:create, :index]
      delete '/genie_rules/:genie_rule_uid', :to => 'genie_rules#destroy'

      resources :email_rules, only: [:create, :index]
      delete '/email_rules/:email_rule_uid', :to => 'email_rules#destroy'
      get '/email_rules/recommended_rules', to: 'email_rules#recommended_rules'

      get '/website_previews/proxy', to: 'website_previews#proxy'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
