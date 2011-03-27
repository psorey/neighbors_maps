#!/usr/bin/env ruby
 resources :comments

  resources :jobs do
    resources :comments
  end

  devise_for :users, :controllers => { :sessions => "user_sessions" },
    :path_names => { :sign_in => 'login', :sign_out => 'logout',  :registration => 'register' }

  # The priority is based upon order of creation:
  # first created -> highest priority.
  resources :profiles

  resources :users do
     member do
       get :edit_password 
       get :update_password
       get :edit_email
       put :update_email
       get :edit_avatar
       put :update_avatar
       get :set_user_login
       get :set_user_email
       get :set_user_address
       get :set_user_first_name
       get :set_user_last_name
       get :set_user_address
       get :set_user_landline
       get :set_user_cell_phone
    end
  end

  resources :announcements
  
  # RESTful rewrites
  
  match  '/opensession' => "sessions#create", :as => "open_id_complete", :requirements => { :method => :get }
  match '/opencreate' => 'users#create',:as => :open_id_create,  :requirements => { :method => :get }
    
  
  # Administration
  namespace :admin do 
    root :to => 'dashboard#index'
    resources :settings
    resources :announcements
    resources :commits
    resources :users do 
      member do 
        put :suspend
        put :unsuspend
        put :activate
        delete :purge
        put :reset_password
        get :set_user_login
        get :set_user_email
        get :set_user_address
        get :set_user_first_name
        get :set_user_last_name
        get :set_user_address
        get :set_user_landline
        get :set_user_cell_phone  
      end
      collection do
        get :pending
        get :active
        get :suspended
        get :deleted
      end
    end
  end
  
  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
  root :to => "dashboard#index"
  
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #match ':controller(/:action(/:id(.:format)))'
  

end


# See how all your routes lay out with "rake routes"
ActionController::Routing::Routes.draw do |map|
  map.resources :jobs, :has_many => :comments

  
  # RESTful rewrites
  
  map.signup   '/signup',   :controller => 'users',    :action => 'new'
  map.register '/register', :controller => 'users',    :action => 'create'
  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate'
  map.login    '/login',    :controller => 'sessions', :action => 'new'
  map.logout   '/logout',   :controller => 'sessions', :action => 'destroy', :conditions => {:method => :delete}
  
  map.user_troubleshooting '/users/troubleshooting', :controller => 'users', :action => 'troubleshooting'
  map.user_forgot_password '/users/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.user_reset_password  '/users/reset_password/:password_reset_code', :controller => 'users', :action => 'reset_password'
  map.user_forgot_login    '/users/forgot_login',    :controller => 'users', :action => 'forgot_login'
  map.user_clueless        '/users/clueless',        :controller => 'users', :action => 'clueless'
  
  map.open_id_complete '/opensession', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.open_id_create '/opencreate', :controller => "users", :action => "create", :requirements => { :method => :get }
    
  map.resources :users, :member => { :edit_password => :get,
                                     :update_password => :put,
                                     :edit_email => :get,
                                     :update_email => :put,
                                     :edit_avatar => :get, 
                                     :update_avatar => :put }
                            
  map.resource :session
    
  # Profiles
  map.resources :profiles
  
  # Administration
  map.namespace(:admin) do |admin|
    admin.root :controller => 'dashboard', :action => 'index'
    admin.resources :settings
    admin.resources :users, :member => { :suspend   => :put,
                                         :unsuspend => :put,
                                         :activate  => :put, 
                                         :purge     => :delete,
                                         :reset_password => :put },
                            :collection => { :pending   => :get,
                                             :active    => :get, 
                                             :suspended => :get, 
                                             :deleted   => :get }
  end
  
  # Dashboard as the default location
  map.root :controller => 'dashboard', :action => 'index'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

