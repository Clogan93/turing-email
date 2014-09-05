Rails.application.routes.draw do
  root 'static_pages#home'
  get '/mail', to: 'static_pages#mail'
  get '/mail2', to: 'static_pages#mail2'

  resources :sessions, only: [:new, :create, :destroy]

  resources :users, only: [:new, :create]
  match('/reset_password', to: 'users#reset_password', via: ['get', 'post'], as: :reset_password)

  match '/gmail_oauth2_callback', to: 'gmail_accounts#oauth2_callback', via: 'get'
  match '/gmail_oauth2_remove', to: 'gmail_accounts#oauth2_remove', via: 'delete', as: :gmail_oauth2_remove

  match '/signup',  to: 'users#new',        via: 'get'
  match '/signin',  to: 'sessions#new',     via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      resources :users, only: [:create]
      match '/users/current', to: 'users#current', via: 'get'

      resources :emails, only: [:show]
      resources :email_folders, only: [:index]
      match '/email_threads/inbox', to: 'email_threads#inbox', via: 'get'
      match '/email_threads/in_folder', to: 'email_threads#in_folder', via: 'get'

      resources :sessions, only: [:create]
      match '/signout', to: 'sessions#destroy', via: 'delete'
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
