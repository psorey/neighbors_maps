class Project < ActiveRecord::Base
  has_many :users
  # has_many :map_layers
  
end
