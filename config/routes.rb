NeighborsMaps::Application.routes.draw do
  resources :features

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'theme_maps#index'
  resources :theme_map_layers
  resources :map_layers
  
  resources :theme_maps do
    get 'revert_geo_db', on: :member
    post 'update_geo_db', on: :member
  end

  resources :theme_maps
  get 'theme_maps/:name' => 'theme_maps#show'

  # main menu items
  resources :forums
  resources :wiki
  resources :about
  resources :guide
  resources :welcome 
  resources :administrators  
  resources :projects  
  
  
  # design resources, maps, photos, videos, cad:
  resources :site_photos
  resources :precompiled_maps
  resources :views
  resources :neighbor_surveys
  resources :walk_surveys
  resources :overall_map
  resources :half_blocks
  resources :neighbors
  resources :greenwood_users
  resources :maps


  # site internals:
  get '/logout' =>  'sessions#destroy'
  get '/login' => 'sessions#new'
  get '/register'=> 'users#create'
  get '/signup' => 'users#new'
  get '/activate/:activation_code' =>  'users#activate', :activation_code => nil

  resources :users
  resource :session
  resources :passwords
  resources :users

  get '/change_password' => 'users#change_password'
  # resources :users , :controller => 'users', :collection => {:change_password_update => :put}
  # map.resources :neighbors, :collection => {:index => :get}
  # example: map.connect 'products/:id', :controller => 'products', :action => 'view'
  get  '/neighbors/:search_column/:match_list' => 'neighbors#index'

end

