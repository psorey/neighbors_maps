
#    * GET is used to retrieve a representation of a known Resource.
#    * POST is used to create a new, dynamically named, Resource. When the client submits non-Atom-Entry representations to a Collection for creation, two Resources are always created -- a Media Entry for the requested Resource, and a Media Link Entry for metadata about the Resource that will appear in the Collection.
#    * PUT is used to edit a known Resource. It is not used for Resource creation.
#    * DELETE is used to remove a known Resource.


GWStreetscapesRails3::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  # match 'logout', :to => 'sessions#destroy', :as => "logout"
  match '/logout' => 'sessions#destroy', :as => 'logout'   #  as in: redirect_to logout_path
  # map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  match '/login' => 'sessions#new'
  # map.login '/login', :controller => 'sessions', :action => 'new'
  match '/register' => 'users#create'
  # map.register '/register', :controller => 'users', :action => 'create'
  match '/signup' => 'users#new'
  # map.signup '/signup', :controller => 'users', :action => 'new'  
  
#  !!! match activate '/activate/:activation_code' =>  'users#activate', :activation_code => nil
#   ??? match '/administrators/:search_keyword' => 'administrators#index' :as => :search_by
  match '/neighbors(/:search_column(/:match_list(/:order_by)))' => 'neighbors#index'
  
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  
  resources :walk_surveys
  resources :overall_map
  resources :administrators
  resources :neighbors
  resources :users
  resources :session
  resources :guide
  resources :map
  resources :welcome
  
#  resources :users do
#    resources :survey_answers
#    resources :roles
#  end
  
  
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
  root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  