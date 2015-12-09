require 'mapscript'
include Mapscript


class MapLayer < ActiveRecord::Base

  has_many :theme_map_layers
  has_many :theme_maps, :through => :theme_map_layers
  has_many :user_lines
  has_many :user_features


  def get_vector_data
    # json  { :
  end
  
  # load features from given table belonging to user
  #
  def load_user_geo_json(usr_id)  #TODO pass in user_id and map_layer_id
    query = <<-SQL
      SELECT row_to_json(fc)
        FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
        FROM ( SELECT 'Feature' As type
      , ST_AsGeoJSON(lg.geometry)::json As geometry
      , lg.id AS id
      , row_to_json((SELECT l FROM (SELECT id, name, text, number, amount) As l
        )) As properties
        FROM ( SELECT * FROM user_features
        WHERE  user_id = #{usr_id} AND map_layer_id = #{self.id}) As lg ) As f ) As fc;
    SQL

     result = ActiveRecord::Base.connection.execute(query)
     tj= JSON.parse(result[0]["row_to_json"])
     if tj["features"] == nil
       return "'none'"
     else
       return result[0]["row_to_json"]
     end
  end


  def self.geo_json_sample
   json = <<-FEATURES
    {"type": "FeatureCollection", "features": [{ "type": "Feature","geometry": { "type": "Point", "coordinates": [-13621522.730645318, 6055608.910350661] }, "properties": { "id": 333,  "name": "user_location", "content": "Sorey"}}]}
FEATURES
   json
  end


end


#bandsitem : string
#classitem : string
#connection : string
#connectiontype : int
#data : string
#debug : int
#dump : int
#extent : rectObj
#filteritem : string
#footer : string
#group : string
#header : string
#index : int immutable
#labelangleitem : string
#labelcache : int
#labelitem : string
#labelmaxscaledenom : float
#labelminscaledenom : float
#labelrequires : string
#labelsizeitem : string
#map : mapObj immutable
#maxfeatures : int
#maxscaledenom : float
#metadata : hashTableObj immutable
#minscaledenom : float
#name : string
#numclasses : int immutable
#numitems : int immutable
#numjoins : int immutable
#numprocessing : int immutable
#offsite : colorObj
#opacity : int
#postlabelcache : int
#requires : string
#sizeunits : int
#status : int
#styleitem : string
#symbolscaledenom : float
#template : string
#tileindex : string
#tileitem : string
#tolerance : float
#toleranceunits : int
#transform : int
#type : int
#units : int
