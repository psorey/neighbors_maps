

class ThemeMapLayer < ActiveRecord::Base
  
  # join model linking layers to theme maps
  # and we can also add modifications to the layers
  #
  belongs_to :theme_map
  belongs_to :map_layer
  
  
end
