require 'mapscript'
include Mapscript


class MapLayer < ActiveRecord::Base

  has_many :theme_map_layers
  has_many :theme_maps, :through => :theme_map_layers
  has_many :user_lines
  belongs_to :source


  def get_vector_data
    # json  { :
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
