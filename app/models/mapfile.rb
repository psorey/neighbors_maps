# Notes on how we create maps in this web application:
#
# Currently using Mapscript-Ruby to manipulate the (Mapserver MapObj) map_object,
# then we save the map_object as a mapfile ('theme_map_name.map') to be
# served as WMS layers through the CGI version of Mapserver, so we can take advantage
# of the OpenLayers WMS layer functions. This does seem a round-about approach;
# the main goal, however, is to simplify the online creation and modification of theme
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
  belongs_to :source

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

=begin
INSERT INTO "mapped_lines"("")

INSERT INTO "Parcels"("Name", the_geom)
    VALUES ('Corrected_Shape', 
    ST_TRANSFORM(ST_GeomFromGeoJSON('{
    "type":"Polygon",
    "coordinates":[[
        [-91.23046875,45.460130637921],
        [-79.8046875,49.837982453085],
        [-69.08203125,43.452918893555],
        [-88.2421875,32.694865977875],
        [-91.23046875,45.460130637921]
    ]],
    "crs":{"type":"name","properties":{"name":"EPSG:4326"}}
}'),3857));



WITH data AS (SELECT '{ "type": "FeatureCollection",
    "features": [
      { "type": "Feature",
        "geometry": {"type": "Point", "coordinates": [102.0, 0.5]},
        "properties": {"prop0": "value0"}
        },
      { "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [
            [102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0]
            ]
          },
        "properties": {
          "prop0": "value0",
          "prop1": 0.0
          }
        },
      { "type": "Feature",
         "geometry": {
           "type": "Polygon",
           "coordinates": [
             [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0],
               [100.0, 1.0], [100.0, 0.0] ]
             ]
         },
         "properties": {
           "prop0": "value0",
           "prop1": {"this": "that"}
           }
         }
       ]
     }'::json AS fc)

SELECT
  row_number() OVER () AS gid,
  ST_AsText(ST_GeomFromGeoJSON(feat->>'geometry')) AS geom,
  feat->'properties' AS properties
FROM (
  SELECT json_array_elements(fc->'features') AS feat
  FROM data
) AS f;


=end






end
