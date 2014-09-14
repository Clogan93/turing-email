Rails.application.routes.draw do
  root 'static_pages#home'
  get '/mail', to: 'static_pages#mail'
  get '/analytics', to: 'static_pages#analytics'

  resources :sessions, only: [:new, :create, :destroy]

  resources :users, only: [:new, :create]
  match('/reset_password', to: 'users#reset_password', via: ['get', 'post'], as: :reset_password)

  match '/gmail_oauth2_callback', to: 'gmail_accounts#o_auth2_callback', via: 'get'
  match '/gmail_o_auth2_remove', to: 'gmail_accounts#o_auth2_remove', via: 'delete'

  match '/signup',  to: 'users#new',        via: 'get'
  match '/signin',  to: 'sessions#new',     via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      resources :users, only: [:create]
      get '/users/current', to: 'users#current'
      post '/users/declare_email_bankruptcy', to: 'users#declare_email_bankruptcy'

      resources :sessions, only: [:create]
      match '/signout', to: 'sessions#destroy', via: 'delete'

      post '/email_accounts/send_email', to: 'email_accounts#send_email'
      
      get '/emails/show/:email_uid', to: 'emails#show'
      post '/emails/set_seen', to: 'emails#set_seen'
      post '/emails/move_to_folder', to: 'emails#move_to_folder'
      post '/emails/apply_gmail_label', to: 'emails#apply_gmail_label'
      post '/emails/remove_from_folder', to: 'emails#remove_from_folder'
      post '/emails/trash', to: 'emails#trash'

      get '/email_threads/show/:email_thread_uid', to: 'email_threads#show'
      match '/email_threads/inbox', to: 'email_threads#inbox', via: 'get'
      match '/email_threads/in_folder', to: 'email_threads#in_folder', via: 'get'
      post '/email_threads/move_to_folder', to: 'email_threads#move_to_folder'
      post '/email_threads/apply_gmail_label', to: 'email_threads#apply_gmail_label'
      post '/email_threads/remove_from_folder', to: 'email_threads#remove_from_folder'
      post '/email_threads/trash', to: 'email_threads#trash'
      
      get '/email_reports/ip_stats', to: 'email_reports#ip_stats'
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
