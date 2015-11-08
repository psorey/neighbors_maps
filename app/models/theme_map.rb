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

  #validates_presence_of :name #, :layer_ids, :base_layer_ids 
  validates_uniqueness_of :name, :message => "that name has already been used"
  validates_format_of :name, :with => /\A[A-Za-z0-9_\-\.\s]+\Z/,
    :message => "only: alpha-numeric, period, underscore, dash, space"
  
  
  # test: make_mapfile should create a Mapfile in the mapserver directory  !!!
  # test: make_mapfile should populate @layer_name_list: array of layer names, downcased and underscored !!!

  def make_mapfile
    # mapscript:
    @map = MapObj.new
    @map.selectOutputFormat('PNG')
    outf = @map.outputformat
    outf.transparent = MS_TRUE
    outf.mimetype = "image/png"
    outf.imagemode = MS_IMAGEMODE_RGBA

    @map.setExtent( 1262053, 205541, 1285032, 260122 )
    @map.debug = 3

    @map.transparent = MS_TRUE
    @map.setConfigOption("MS_ERROR_FILE", "/home/paul/mapserver/error.log")
    @map.setSymbolSet(APP_CONFIG['MAPSERVER_SYMBOL_FILE'])
    @map.setFontSet(APP_CONFIG['MAPSERVER_FONTS_FILE'])
    @map.shapepath = APP_CONFIG['MAPSERVER_DIRECTORY'] + "data"
    @map.setProjection("init=epsg:2926")
    # @map.setProjection(APP_CONFIG['MAPSERVER_PROJECTION'])
    @map.web.metadata.set("wms_enable_request", "GetMap GetCapabilities GetFeatureInfo GetLegendGraphic")
    @map.web.metadata.set("wms_title", "#{self.name.dashed}")
    @map.web.metadata.set("wms_onlineresource", "localhost/cgi-bin/mapserv?map=#{mapfile_name}&")
    @map.web.metadata.set("wms_srs", "EPSG:4326 EPSG:3857")
    @map.web.metadata.set("wms_feature_info_mime_type", "text/html")
    @map.units = MS_FEET
    add_ordered_layers
    @map.save("/home/paul/mapserver/my_recent_map.map")
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
    # load the layer descriptions into the MapObj
    temp_layers = []
    self.map_layers.each do |layer|
      temp_layers << layer
    end
    temp_layers.sort! { |a,b| a.draw_order <=> b.draw_order }
    temp_layers.each do |map_layer|
      layer = LayerObj.new(@map)  # mapscript
      layer.debug = 3
      layer.updateFromString(map_layer.layer_mapfile_text)  # mapscript
      mapfile_layer_name = map_layer.name.dashed
      layer.name = mapfile_layer_name
    end
  end


  # test: get_theme_layers should return an array of map_layer id's  !!!
  #       corresponding to the theme_map_layers !!!
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


  def test
query = <<-SQL
       WITH data AS (SELECT #{geo_json_sample}::json AS fc)
       INSERT INTO user_lines (id, geometry, properties) SELECT
         (feat->>'id')::int AS id,
         ST_SetSRID(ST_GeomFromGeoJSON(feat->>'geometry'),3857) AS geometry,
         feat->'properties' AS properties
         FROM (
         SELECT json_array_elements(fc->'features') AS feat
         FROM data ) AS f;
SQL
     result = ActiveRecord::Base.connection.execute(query)
     result.each do |r|
       logger.debug "result:"
       logger.debug r.inspect
     end
     result
  end



 def geo_json_sample
   json = <<-FEATURES
    '{
      "type": "FeatureCollection",
        "features": [{
           "type": "Feature",
           "id" : 333,
           "geometry": { "type": "LineString",
             "coordinates": [[-13621522.730645318, 6055608.910350661],[ -13621083.217732677, 6055284.052980449], \
               [ -13620165.973393254, 6055312.7168660555], [-13619841.116023043, 6055112.069666808], \
               [ -13619119.496548858, 6055252.217636055]]
           },
           "properties": {
             "name": "my_path_1",
             "content": "This is where I like to go when I take a walk.",
             "qty":"5"
           }
         },
         {
           "type": "Feature",
           "id": 747,
             "geometry": { "type": "LineString",
                           "coordinates": [[-13621589.613045067, 6056440.163033262],[ -13621446.29361703, 6056745.911146402], \
               [ -13619602.250309652, 6056487.936175941],[ -13619153.182768477, 6056573.927832761]]
           },
           "properties": {
             "name": "my_path_2",
             "content": "walking to grocery store",
             "qty":"2"
           }
         }
        ]}'
     FEATURES
   json
 end

end





