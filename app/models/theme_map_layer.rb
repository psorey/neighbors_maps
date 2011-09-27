

class ThemeMapLayer < ActiveRecord::Base
  
  # join model linking layers to theme maps
  # and we can also add modifications to the layers:
  #   opacity, line width, line color, fill color, specify base layer, layer order

  belongs_to :theme_map
  belongs_to :map_layer
  
  validates_numericality_of :opacity, :line_width, :only_integer => true, :allow_nil => true, :message => "must be integer"
  validates_inclusion_of :opacity, :in => 0..100, :message => "can only be between 0 and 100.", :allow_nil => true 
  validates_format_of :line_color, :with => /^#[a-fA-F0-9]{6}$/, :message => "must be hex color format: #ffffff ", :allow_nil => true
  validates_format_of :fill_color, :with => /^#[a-fA-F0-9]{6}$/, :message => "must be hex color format: #ffffff ", :allow_nil => true

end
