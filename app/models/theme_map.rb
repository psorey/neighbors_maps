require 'mapscript'
include Mapscript

class ThemeMap < ActiveRecord::Base
  before_create :create_slug

  has_many :theme_map_layers, :dependent => :delete_all
  has_many :map_layers, :through => :theme_map_layers
  attr_accessor :map, :layer_name_list # these are helpful for cleaning up model code
                                       # and for passing attributes to views more easily
  
  # is_base_layer: necessary for OpenLayers display; a base layer will be set up as transparent:false 
  
  # test: make_mapfile should create a Mapfile in the mapserver directory  !!!
  # test: make_mapfile should populate @layer_name_list: array of layer names, downcased and underscored !!!  
  def make_mapfile
    # set up map parameters -- load these from config.yml file...!!!
    # MapObj and LayerObj are Mapscript classes...
    @map = MapObj.new
    @map.setSymbolSet(APP_CONFIG['MAPSERVER_SYMBOL_FILE'])
    @map.setFontSet(APP_CONFIG['MAPSERVER_FONTS_FILE'])
    @map.shapepath = APP_CONFIG['MAPSERVER_DIRECTORY'] + "data"
    #@map.setExtent(1255053.87242477, 239541.583313177, 1279032.27152446, 266122.634434438)
    @map.setProjection(APP_CONFIG['MAPSERVER_PROJECTION'])
    
    add_ordered_layers
    
    # save the MapObj as a Mapfile
    @map.save(APP_CONFIG['MAPSERVER_DIRECTORY'] + "#{self.name.downcase.gsub(/\s+/, "_")}.map")
  end
  
  
  def add_ordered_layers
    @layer_name_list = []
    # load the layer descriptions into the MapObj
    theme_map_layers = ThemeMapLayer.find(:all, :conditions => {:theme_map_id => self.id})
    map_layers = []
    theme_map_layers.each do |tml|
      map_layers << tml.map_layer
    end
    map_layers.sort! { |a,b| a.draw_order <=> b.draw_order }
    map_layers.each do |map_layer|
      layer = LayerObj.new(@map)
      layer.updateFromString(map_layer.layer_mapfile_text)
      mapfile_layer_name = map_layer.name.downcase.gsub(/\s+/, "_")
      layer.name = mapfile_layer_name
      @layer_name_list << mapfile_layer_name
    end
  end
  
  # test: all the different scenarios...
  def update_layers (map_layers, base_layers)
    # map_layers: array of map_layer_id (strings) that are map_layers in self.theme_map_layers
    #    some of which may already already referenced by self.theme_map_layers,
    #    others of which may need to be created...
    # base_layers: array of map_layer_id (strings) that are defined as base_layers in self.theme_map_layers
    #    see comment above...
    # and be sure to destroy theme_map_layers that are removed from the theme map...
    current_map_layer_ids = []  
    self.theme_map_layers.each do |tml|
      if !map_layers.include?(tml.id.to_s)
        tml.delete
      else
        current_map_layer_ids << tml.map_layer_id.to_s  # make these strings too
      end
    end
    # looks like we end up instantiating a ThemeMapLayer one way or another...
    # so refactor to check if base_layer only once!!!
    map_layers.each do |map_layer_id|
      if current_map_layer_ids.include?(map_layer_id)
        theme_map_layer = ThemeMapLayer.find(:first, :conditions => {:map_layer_id => map_layer_id.to_i, :theme_map_id => self.id})
        if theme_map_layer  # refactor this! !!!
          if base_layers.include?(map_layer_id)
            theme_map_layer.is_base_layer = true
          else
            theme_map_layer.is_base_layer = false
          end
        else
            # throw exception ?? notify of error?
        end
      else
        theme_map_layer = self.theme_map_layers.create(:map_layer_id => map_layer_id.to_i, :theme_map_id => self.id)   
        if base_layers.include?(map_layer_id)
          theme_map_layer.is_base_layer = true
        else
          theme_map_layer.is_base_layer = false
        end
        theme_map_layer.save
      end
    end
  end
  
  
  # test: get_theme_layers should return an array of map_layer id's  !!!
  #       corresponding to the theme_map_layers !!!
  def get_theme_layers
    theme_layers = ThemeMapLayer.find(:all, :conditions => {:theme_map_id => self.id})
    layer_id_list = []
    base_id_list = []
    theme_map_layers.each do |tml|
      layer_id_list << tml.map_layer_id
      if tml.is_base_layer
        base_id_list << tml.map_layer_id
      end
    end
    return theme_layers, layer_id_list, base_id_list
  end
  
  
  def to_param
    slug
  end


  def create_slug
    self.slug = self.name.parameterize
  end
  
end
