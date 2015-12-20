# Notes on how we create maps in this web application:

# Currently using Mapscript-Ruby to manipulate the (Mapserver MapObj) map_object,
# then we save the map_object as a mapfile ('theme_map_name.map') to be
# served as WMS layers through the CGI version of Mapserver, so we can take advantage
# of the OpenLayers WMS layer functions. This does seem a round-about approach;
# the main goal, however, is to simplify the on-line creation and modification of theme
# maps, and the present method does that well.
# There may be an alternative using the Mapscript version of Mapserver
# to send layers to the OpenLayers interface directly from the MapObj.

# In practice, the easiest path to great-looking on-line maps is to design their 'look and feel'
# in a desktop GIS application such as QGIS, export a mapfile from QGIS, snip the
# individual layers from the mapfile, then use the snippets to create 'map_layers'
# in this web application, where they can be further tweaked and used in many different maps.

# MapObj and LayerObj are Mapscript classes.

# TODO:
# Add 'Export Mapfile' function so a theme_map can be viewed in desktop GIS applications.
# Add OPACITY, WIDTH and COLOR attributes to theme_map_layer objects that override values set in map_layers.
#


require 'mapscript'
include Mapscript

class ThemeMap < ActiveRecord::Base

  has_many :theme_map_layers # :dependent => :delete_all
  has_many :map_layers, :through => :theme_map_layers
  has_many :user_lines, :through => :map_layers
  has_many :vector_features, :through => :map_layers

  accepts_nested_attributes_for :theme_map_layers, allow_destroy: true
  accepts_nested_attributes_for :map_layers

  attr_accessor :layer_name_list, :base_layer_ids, :layer_ids   # passed as params but not saved


  #validates_presence_of :name #, :layer_ids, :base_layer_ids 
  validates_uniqueness_of :name, :message => "that name has already been used"
  validates_format_of :name, :with => /\A[A-Za-z0-9_\-\.\s]+\Z/,
    :message => "only: alpha-numeric, period, underscore, dash, space"



  def as_json
    context = ApplicationController.new.view_context
    context.render('/theme_maps/theme_map.json.jbuilder', theme_map: self)
  end


  # test: make_mapfile should create a Mapfile in the mapserver directory  
  # test: make_mapfile should populate @layer_name_list: array of layer names, downcased and underscored 
  # TODO: factor out to mapfile.rb


  def make_mapfile
    # mapscript:
    @map = MapObj.new
    @map.selectOutputFormat('PNG')
    outf = @map.outputformat
    outf.transparent = MS_TRUE
    outf.mimetype = "image/png"
    outf.imagemode = MS_IMAGEMODE_RGBA
   # @map.setExtent( 1262053, 205541, 1285032, 260122 )
    @map.debug = 5
    # colorobj = ColorObj.new
    # colorobj.imagecolor(255,255,255)
    # logger.debug @map.colorObj.setRGB(255,255,255)
    # @map.transparent = MS_TRUE


    @map.setConfigOption("MS_ERRORFILE", "/home/paul/mapserver/error.log")
    @map.setSymbolSet(APP_CONFIG['MAPSERVER_SYMBOL_FILE'])
    @map.setFontSet(APP_CONFIG['MAPSERVER_FONTS_FILE'])
    @map.shapepath = APP_CONFIG['MAPSERVER_DIRECTORY'] + "data"
    @map.setProjection("init=epsg:2926")
    @map.web.metadata.set("wms_enable_request", "GetMap GetCapabilities GetFeatureInfo GetLegendGraphic")
    @map.web.metadata.set("wms_title", "#{self.name.dashed}")
    @map.web.metadata.set("wms_onlineresource", "#{APP_CONFIG['MAPSERVER_URL']}" + "#{self.name.dashed}" +'&')

    #MAPSERVER_URL: 'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/'
    @map.web.metadata.set("wms_srs", "EPSG:4326 EPSG:3857")
    @map.web.metadata.set("wms_feature_info_mime_type", "text/html")
    @map.units = MS_FEET
    add_ordered_layers
    @map.save("/home/paul/mapserver/gs_team_study_areas.map") # add session_id to filename for concurrent users
  end


  def get_summary_description          # returns first paragraph of @theme_map.description
    self.description.split("\n")[0]    #
  end


  def mapfile_url
    APP_CONFIG['MAPSERVER_URL'] + "#{self.name.dashed}.map"
  end


  def mapfile_name
    APP_CONFIG['MAPSERVER_DIRECTORY'] + "#{self.name.dashed}.map"
  end


  def sort_layers
    self.theme_map_layers.sort!{ |a,b| a.draw_order <=> b.draw_order }
  end



  def add_ordered_layers
    #return
    temp_layers = []
    self.theme_map_layers.each do |layer|
      temp_layers << layer
    end
    temp_layers.sort! { |a,b| a.draw_order <=> b.draw_order }
    temp_layers.each do |theme_map_layer|
      if theme_map_layer.map_layer.layer_mapfile_text != ""
        layer = LayerObj.new(@map)  # mapscript
        layer.debug = 3
        layer.updateFromString(theme_map_layer.map_layer.layer_mapfile_text)  # mapscript
      end
    end
  end



  # test: get_theme_layers should return an array of map_layer id's  
  #       corresponding to the theme_map_layers 
  def get_theme_layers
    layer_id_list = []
    base_id_list = []
    self.theme_map_layers.each do |tml|
      layer_id_list << tml.map_layer_id
      if tml.is_base_layer
        base_id_list << tml.map_layer_id
      end
    end
    return layer_id_list, base_id_list
  end



  def to_param
    self.slug = self.name.parameterize
  end


end





