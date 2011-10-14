# Notes on how we create maps in this web application:
#
# Currently using Mapscript-Ruby to manipulate the (Mapserver MapObj) map_object,
# then we save the map_object as a mapfile ('theme_map_name.map') to be
# served as WMS layers through the CGI version of Mapserver, so we can take advantage
# of the OpenLayers WMS layer functions. This does seem a round-about approach;
# the main goal, however, is to simplify the on-line creation and modification of theme
# maps, and the present method does that well.
# There may be an alternative using the Mapscript version of Mapserver
# to send layers to the OpenLayers interface directly from the MapObj.
#
# In practice, the easiest path to great looking on-line maps is to design their 'look and feel'
# in a desktop GIS application such as QGIS, export a mapfile from QGIS, snip the
# individual layers from the mapfile, then use the snippets to create 'map_layers'
# in this web application, where they can be further tweaked and used in many different maps.
#
# MapObj and LayerObj are Mapscript classes.
 
# TODO:
# Add 'Export Mapfile' function so a theme_map can be viewed in desktop GIS applications.
# Add OPACITY, WIDTH and COLOR attributes to theme_map_layer objects that override values set in map_layers.

require 'mapscript'
include Mapscript

class ThemeMap < ActiveRecord::Base
  
  has_many :theme_map_layers, :dependent => :delete_all
  has_many :map_layers, :through => :theme_map_layers
  
  attr_accessor :map     # make the MapObj accessible to methods
  attr_accessor :layer_name_list, :base_layer_ids, :layer_ids   # passed as params but not saved
  
  validates_presence_of :name, :layer_ids, :base_layer_ids 
  validates_uniqueness_of :slug, :name, :message => "that name has already been used"
  validates_format_of :name, :with => /\A[A-Za-z0-9_\-\.\s]+\Z/,
            :message => "only: alpha-numeric, period, underscore, dash, space"

  before_create :create_slug
  
  # test: make_mapfile should create a Mapfile in the mapserver directory  !!!
  # test: make_mapfile should populate @layer_name_list: array of layer names, downcased and underscored !!!
  def make_mapfile
    # mapscript:
    @map = MapObj.new
    @map.setSymbolSet(APP_CONFIG['MAPSERVER_SYMBOL_FILE'])
    @map.setFontSet(APP_CONFIG['MAPSERVER_FONTS_FILE'])
    @map.shapepath = APP_CONFIG['MAPSERVER_DIRECTORY'] + "data"
    #@map.setExtent(1264053.87242477, 245541.583313177, 1275032.27152446, 260122.634434438)
    @map.setProjection(APP_CONFIG['MAPSERVER_PROJECTION'])
    add_ordered_layers
    @map.save(mapfile_name)
  end
  
  
  def get_summary_description  # returns first paragraph of @theme_map.description
    self.description.split("\n")[0]
  end
  
  
  def mapfile_url
    APP_CONFIG['MAPSERVER_URL'] + "#{self.name.dashed}.map"
  end
  
  
  def mapfile_name
    APP_CONFIG['MAPSERVER_DIRECTORY'] + "#{self.name.dashed}.map"
  end
  
  
  def add_ordered_layers
    @layer_name_list = []
    # load the layer descriptions into the MapObj
    # wait...do we have to load them explicitly or just do self.theme_map_layers.each ???
    if theme_map_layers = ThemeMapLayer.find(:all, :conditions => {:theme_map_id => self.id})
      map_layers = []
      theme_map_layers.each do |tml|
        map_layers << tml.map_layer
      end
      map_layers.sort! { |a,b| a.draw_order <=> b.draw_order }
      map_layers.each do |map_layer|
        layer = LayerObj.new(@map)  # mapscript
        layer.updateFromString(map_layer.layer_mapfile_text)  # mapscript
        mapfile_layer_name = map_layer.name.dashed
        layer.name = mapfile_layer_name
        @layer_name_list << mapfile_layer_name
      end
    else
      logger.debug "no layers "
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
    # make a list of all the existing theme_map_layers that are still selected
    # and delete theme_map_layers that were de-selected
    self.theme_map_layers.each do |tml|
      logger.debug "ThemeMap.update_layers: are we loading these from the database here?"
      if !map_layers.include?(tml.id.to_s)
        tml.delete
      else
        current_map_layer_ids << tml.map_layer_id.to_s  
      end
    end
    # looks like we end up instantiating a ThemeMapLayer one way or another...
    # so refactor to check if base_layer only once.  !!!
    
    # now load those existing theme_map_layers from the DB to see if they're base layers
    #    and modify accordingly,
    # then create the new theme_map_layers flagging them base layers if needed...
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
        is_base_layer = base_layers.include?(map_layer_id)
        theme_map_layer = self.theme_map_layers.create(:map_layer_id => map_layer_id.to_i,
                        :theme_map_id => self.id, :is_base_layer => is_base_layer)   
        theme_map_layer.save 
      end
    end
  end
  
  
  # test: get_theme_layers should return an array of map_layer id's  !!!
  #       corresponding to the theme_map_layers !!!
  def get_theme_layers
    layer_id_list = []
    base_id_list = []
    self.theme_map_layers.each do |tml|
      logger.debug "Theme_map.get_theme_layers: are we loading from db?"
      layer_id_list << tml.map_layer_id
      if tml.is_base_layer
        base_id_list << tml.map_layer_id
      end
    end
    return layer_id_list, base_id_list
  end
  
  
  def to_param
    slug
  end


  def create_slug
    self.slug = self.name.parameterize
  end
  
end
