# rails 2.8.5 routes.rb

ActionController::Routing::Routes.draw do |map|
  
  
  # main menu items
  map.resources :forums
  map.resources :wiki
  map.resources :about
  map.resources :guide
  map.resources :welcome 
  map.resources :administrators  
  map.resources :projects  
  
  
  # design resources, maps, photos, videos, cad:
  map.resources :site_photos
  map.resources :precompiled_maps
  map.resources :views
  map.resources :map_layers
  map.resources :neighbor_surveys
  map.resources :walk_surveys
  map.resources :overall_map
  map.resources :half_blocks
  map.resources :neighbors
  map.resources :greenwood_users
  map.resources :maps


  # site internals:
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller =>  'users', :action => 'activate', :activation_code => nil
  map.resources :users
  map.resource :session
  
  map.resources :passwords
  map.resources :users, :has_one => [:password]

  #map.change_password '/change_password', :controller => 'users', :action => 'change_password'
  #map.resources :users , :controller => 'users', :collection => {:change_password_update => :put}



  # map.resources :neighbors, :collection => {:index => :get}
  # example: map.connect 'products/:id', :controller => 'products', :action => 'view'
  map.connect 'neighbors/:search_column/:match_list', :controller => 'neighbors', :action => 'index'

# map.activate '/activate/:activation_code', :controller  => 'users', :action => 'activate'
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end