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


end
