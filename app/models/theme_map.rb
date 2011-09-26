require 'mapscript'
include Mapscript

class ThemeMap < ActiveRecord::Base
  
  has_many :theme_map_layers, :dependent => :delete_all
  has_many :map_layers, :through => :theme_map_layers
 
  def make_mapfile
    # set up map parameters -- we'll do this  another way soon...
    # MapObj and LayerObj are Mapscript classes...
    map = MapObj.new
    map.setSymbolSet("/home/paul/mapserver/symbols/simple_symbols.txt")
    map.setFontSet("/home/paul/mapserver/fonts/fonts.txt")
    map.shapepath = "/home/paul/mapserver/data"
    
    # these will need to change dynamically with user input (zoom, pan, scroll)
    map.height = 500
    map.width = 700  
    map.setExtent(1255053.87242477, 239541.583313177, 1279032.27152446, 266122.634434438)
    map.setProjection("init=epsg:4326")

    layer_list = []
    # load the layer descriptions into the MapObj
    self.theme_map_layers.each do |tml|
      layer = LayerObj.new(map)
      layer.updateFromString(tml.map_layer.layer_mapfile_text)
      mapfile_layer_name = tml.map_layer.name.downcase.gsub(/\s+/, "_")
      layer.name = mapfile_layer_name
      layer_list << mapfile_layer_name
    end

    map.save("/home/paul/mapserver/#{self.name.downcase.gsub(/\s+/, "_")}.map")
    #img = map.draw
    #img.save('public/images/testmap.png')
    #layer_list.join(',')
    layer_list
  end
  
 
 
end
