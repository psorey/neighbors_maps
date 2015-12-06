
class ThemeMapLayer < ActiveRecord::Base

  # join-model linking layers to theme maps
  #   and we can also modify default map_layer styles where ThemeMapLayer attr's override MapLayer attr's:
  #     opacity, line width, line color, fill color, 
  #   and add new properties: is_base_layer, draw_order

  belongs_to :theme_map
  belongs_to :map_layer
 
#  validates_numericality_of :draw_order, :only_integer => true, :allow_nil => false, :message => 'must be an integer between 0 and 100'
#  validates_inclusion_of :draw_order, :in => 0..100, :message => "can only be between 0 and 100.", :allow_nil => false
#  validates_uniqueness_of :draw_order, :message => 'must be unique'

#TODO: implement these:

 # validates_numericality_of :opacity, :line_width, :only_integer => true, :allow_nil => true, :message => "must be integer"
 # validates_inclusion_of :opacity, :in => 0..100, :message => "can only be between 0 and 100.", :allow_nil => true 
 # validates_format_of :line_color, :with => /^#[a-fA-F0-9]{6}$/, :message => "must be hex color format: #ffffff ", :allow_nil => true
 # validates_format_of :fill_color, :with => /^#[a-fA-F0-9]{6}$/, :message => "must be hex color format: #ffffff ", :allow_nil => true

end
