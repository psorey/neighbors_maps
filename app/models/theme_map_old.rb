require 'mapscript'
include Mapscript

# define the composition of a theme_map, consisting of map_layers
#   define the layer attributes? modify defaults defined in map_layers?
#   instead, we could have 'views' that define the graphical representation of
#      each layer, their order, etc. in which case a theme_map is simply a list of map_layers
#      with a default view defined by the mapfile.
#   On the other hand, the mapfile is analogous to a MapObj which is in essence a view
#      of a series of shapefile layers.
#
# The theme_map is analogous to the OpenLayers javascript in each of the html.erb files
#   so does it *replace* them?
# Does the theme_map simply instruct OpenLayers how to arrange and display the layers?
#    We could start out that way and see how it goes.
# Is the default view represented in the mapfile, and then we modify it as needed?
# Theme maps will also include user-input layers
# Each user (viewer) could also maintain their own view settings that override defaults
# 

class ThemeMap < ActiveRecord::Base
  
  has_many :map_layers
  belongs_to_many :viewers
  
  attr_accessible :name, :description, :map_layers, 
end
