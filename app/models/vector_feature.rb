require 'rgeo/geo_json'

class VectorFeature < ActiveRecord::Base


  include ActionView::Helpers::OutputSafetyHelper

  belongs_to :map_layer
  belongs_to :user
  
  # load all vector_features on map_layer, or only those of current user...
  def self.load_geo_json(map_layer_id, only_current_user = false) 
    current_user_sql = ""
    if only_current_user == true
      current_user_sql = "user_id = #{current_user.id} AND "
    end
    query = <<-SQL
      SELECT row_to_json(fc)
        FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
        FROM ( SELECT 'Feature' As type
      , ST_AsGeoJSON(lg.geometry)::json As geometry
      , lg.id AS id
      , row_to_json((SELECT l FROM (SELECT id, value, text, number, amount) As l
        )) As properties
        FROM ( SELECT * FROM vector_features 
        WHERE #{ current_user_sql } map_layer_id = #{map_layer_id}) As lg ) As f ) As fc;
    SQL
     result = ActiveRecord::Base.connection.execute(query)
     tj= JSON.parse(result[0]["row_to_json"])
     if tj["features"] == nil
       return "'none'"
     else
       return result[0]["row_to_json"]
     end
  end


  def as_geo_json
    query = <<-SQL
       SELECT row_to_json(fc)
        FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
        FROM ( SELECT 'Feature' As type
      , ST_AsGeoJSON(lg.geometry)::json As geometry
      , lg.id AS id
      , row_to_json((SELECT l FROM (SELECT id, value, text, number, amount) As l
        )) As properties
        FROM ( SELECT * FROM vector_features 
        WHERE id = #{self.id}) As lg ) As f ) As fc;
    SQL
     
  end


  def self.test_features
     json = <<-FEATURES
    {"type": "FeatureCollection", "features": [{ "type": "Feature","geometry": { "type": "LineString", "coordinates": [[-13621522.730645318, 6055608.910350661],[ -13621083.217732677, 6055284.052980449], [ -13620165.973393254, 6055312.7168660555], [-13619841.116023043, 6055112.069666808], [ -13619119.496548858, 6055252.217636055]] }, "properties": { "id": 333,  "value": "my_path_1", "text": "This is where I like to go when I take a walk.", "number":"5"} },
    { "type": "Feature","geometry": { "type": "LineString", "coordinates": [[-13621589.613045067, 6056440.163033262],[ -13621446.29361703, 6056745.911146402], [ -13619602.250309652, 6056487.936175941],[ -13619153.182768477, 6056573.927832761]] },"properties": { "id": 757,  "value": "my_path_2", "text": "walking to grocery store", "number":"2"}} ]}
FEATURES
  end


  def from_json(json)
    jp = JSON.parse json
    f = jp["features"][0]
    feature = RGeo::GeoJSON.decode( json, json_parser: :json )[1]
    wkt_string  = feature.geometry.as_text
    g_factory = RGeo::Cartesian::Factory.new(srid: 3857)
    self.geometry = g_factory.parse_wkt(wkt_string)
      
  end

  def self.to_mercator(geom)
    proj4_2926 = '+proj=lcc +lat_1=48.73333333333333 +lat_2=47.5 +lat_0=47 +lon_0=-120.8333333333333 +x_0=500000.0001016001' +
                  ' +y_0=0 +ellps=GRS80 +to_meter=0.3048006096012192 +no_defs'

    wkt_2926 = <<-WKT
              'PROJCS["NAD83(HARN) / Washington North (ftUS)",GEOGCS["NAD83(HARN)",
                DATUM["NAD83_High_Accuracy_Regional_Network",SPHEROID["GRS 1980",6378137,298.257222101,
                AUTHORITY["EPSG","7019"]],AUTHORITY["EPSG","6152"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],
                UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4152"]],
                UNIT["US survey foot",0.3048006096012192,AUTHORITY["EPSG","9003"]],
                PROJECTION["Lambert_Conformal_Conic_2SP"],PARAMETER["standard_parallel_1",48.73333333333333],
                PARAMETER["standard_parallel_2",47.5],PARAMETER["latitude_of_origin",47],PARAMETER["central_meridian",
                -120.8333333333333],PARAMETER["false_easting",1640416.667],PARAMETER["false_northing",0],
                AUTHORITY["EPSG","2926"],AXIS["X",EAST],AXIS["Y",NORTH]]'
                WKT

    proj4_3857 = '+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs'

    wkt_3857 = <<-WKT
               'PROJCS["WGS 84 / Pseudo-Mercator",GEOGCS["Popular Visualisation CRS",DATUM["Popular_Visualisation_Datum",
               SPHEROID["Popular Visualisation Sphere",6378137,0,AUTHORITY["EPSG","7059"]],TOWGS84[0,0,0,0,0,0,0],
               AUTHORITY["EPSG","6055"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],
               UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4055"]],
               UNIT["metre",1,AUTHORITY["EPSG","9001"]],PROJECTION["Mercator_1SP"],
               PARAMETER["central_meridian",0],PARAMETER["scale_factor",1],PARAMETER["false_easting",0],
               PARAMETER["false_northing",0],AUTHORITY["EPSG","3785"],AXIS["X",EAST],AXIS["Y",NORTH]]'
               WKT

    factory_2926 = RGeo::Cartesian.factory(:srid => 2926, :proj4 => proj4_2926, :coord_sys => wkt_2926)
    factory_3857 = RGeo::Cartesian.factory(:srid => 3875, :proj4 => proj4_3857, :coord_sys => wkt_3857)
    temp_geom = RGeo::Feature.cast(geom, factory: factory_2926, project: false)
    new_geom = RGeo::Feature.cast(temp_geom, factory: factory_3857, project: true)
  end

  def self.to_vector_feature(neighbor)
    vf = VectorFeature.new
    vf.user_id = neighbor.user_id
    vf.map_layer_id = 33
    vf.value = neighbor.last_name1
    vf.geometry = VectorFeature::to_mercator neighbor.location
    vf.save
  end

end
