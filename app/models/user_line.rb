require 'rgeo/geo_json'
class UserLine < ActiveRecord::Base
include ActionView::Helpers::OutputSafetyHelper


  belongs_to :map_layers


  def save_geo_json
    query = <<-SQL
       WITH data AS (SELECT #{geo_json_sample}::json AS fc)
       INSERT INTO user_lines (id, geometry, name, text, number, value) SELECT
         (feat->>'id')::int AS id,
         ST_SetSRID(ST_GeomFromGeoJSON(feat->>'geometry'),3857) AS geometry,
         feat->'properties
         FROM (
         SELECT json_array_elements(fc->'features') AS feat
         FROM data ) AS f;
     SQL
     result = ActiveRecord::Base.connection.execute(query)
  end


  def self.load_geo_json # for properties in separate columns
    query = <<-SQL
      SELECT row_to_json(fc)
        FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
        FROM (SELECT 'Feature' As type
      , ST_AsGeoJSON(lg.geometry)::json As geometry
      , lg.id AS id
      , row_to_json((SELECT l FROM (SELECT id, name, text, number, amount) As l
        )) As properties
        FROM user_lines As lg ) As f )  As fc;
    SQL
     result = ActiveRecord::Base.connection.execute(query)
     temp = result[0]["row_to_json"]
     logger.debug "temp"
     logger.debug temp.inspect
    temp
  end


  def self.geo_json_sample

   json = <<-FEATURES
    {"type": "FeatureCollection", "features": [{ "type": "Feature","geometry": { "type": "LineString", "coordinates": [[-13621522.730645318, 6055608.910350661],[ -13621083.217732677, 6055284.052980449], [ -13620165.973393254, 6055312.7168660555], [-13619841.116023043, 6055112.069666808], [ -13619119.496548858, 6055252.217636055]] }, "properties": { "id": 333,  "name": "my_path_1", "content": "This is where I like to go when I take a walk.", "qty":"5"} },{ "type": "Feature","geometry": { "type": "LineString", "coordinates": [[-13621589.613045067, 6056440.163033262],[ -13621446.29361703, 6056745.911146402], [ -13619602.250309652, 6056487.936175941],[ -13619153.182768477, 6056573.927832761]] },"properties": { "id": 747,  "name": "my_path_2", "content": "walking to grocery store", "qty":"2"}} ]}
FEATURES

    json

  end

end


