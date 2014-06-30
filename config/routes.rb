NeighborsMaps::Application.routes.draw do

  root 'welcome#index'
  resources :welcome 
  
  post 'theme_maps/:slug/update_geo_db' => 'theme_maps#update_geo_db'
  get 'theme_maps/:slug/revert_geo_db' => 'theme_maps#revert_geo_db'
  get 'theme_maps/:slug/send_help' => 'theme_maps#send_help'
  get 'theme_maps/:slug' => 'theme_maps#show'
  post 'theme_maps/:slug' => 'theme_maps#show'

  
  resources :theme_maps 
  resources :theme_map_layers
  resources :map_layers

  
  resources :neighbor_surveys
  resources :walk_surveys
  resources :overall_map
  resources :half_blocks
  resources :neighbors


  # resources :maps
  # main menu items:
  # resources :forums
  # resources :wiki
  # resources :about
  # resources :guide
  # resources :administrators  
  # resources :projects  
  # design resources, maps, photos, videos, cad:
  # resources :site_photos
  # resources :precompiled_maps
  # resources :views


  # site internals:
  # get '/logout'   =>  'sessions#destroy'
  # get '/login'    => 'sessions#new'
  # get '/register' => 'users#create'
  # get '/signup'   => 'users#new'
  # get '/activate/:activation_code' =>  'users#activate', :activation_code => nil
  # get '/neighbors/:search_column/:match_list' => 'neighbors#index'
  # get '/change_password' => 'users#change_password'
  # resources :users
  # resource :session
  # resources :passwords


end

