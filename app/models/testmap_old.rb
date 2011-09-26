require 'mapscript'
include Mapscript
  require 'rubygems'
  require 'active_record'
  require 'active_model'
  include ActiveRecord
  include ActiveModel
module Mapscript
  class MapObj
    
    


    def mysave
      
    end
    
    def inspect
      #puts msGetVersion
      puts symbolset.inspect
      puts symbolset.numsymbols
      for i in 0..symbolset.numsymbols - 1
        symbol = symbolset.getSymbol(i)
        puts "  symbol name: #{symbol.name}"
      end
      puts self.display
      puts "shapepath: #{shapepath}"
      puts "image size: #{width} X #{height}"
      puts "extent: #{extent.toString}"
      for i in 0..numlayers-1
        layer = getLayer(i)
        puts layer.display
        puts "  layer.name: #{layer.name}"
        for k in 0...layer.numclasses
          klass = layer.getClass(k)
          puts "    class.name #{klass.name}"           
        end
      end
    end
  end
end

    filename = ARGV[0]
    shapefile = ShapefileObj.new(filename, -1)
    
    #symbolset = SymbolSetObj.new("symbols.txt")

    shapepath = File.dirname(filename)
    shapename = File.basename(filename, "....")
    
    map = MapObj.new('')
    map.setSymbolSet("symbols.txt")
    map.shapepath = shapepath
    map.height = 500
    map.width = 700
    map.extent = shapefile.bounds
    
    $shapetypes =
    {
       MS_SHAPEFILE_POINT      => MS_LAYER_POINT,
       MS_SHAPEFILE_ARC        => MS_LAYER_LINE,
       MS_SHAPEFILE_POLYGON    => MS_LAYER_POLYGON,
       MS_SHAPEFILE_MULTIPOINT => MS_LAYER_LINE
    }
    
    layer = LayerObj.new(map)
    layer.name = shapename
    #layer.type = $shapetypes[shapefile.type]
    layer.type = MS_LAYER_LINE
    layer.status = MS_ON
    layer.data = shapename
    
    cls = ClassObj.new(layer)
    style = StyleObj.new(cls)
    color = ColorObj.new()
    color.red = 107
    color.green = 158
    color.blue = 160
    style.color = color
    
    layer = LayerObj.new(map)
    layer.name = 'neighbors'
    layer.type = MS_LAYER_POINT
    layer.status = MS_ON
    layer.setConnectionType(MS_POSTGIS, nil)
    layer.connection = "host=localhost dbname=greenwood_dev user=paul password=kgb0186 port=5432"
    layer.data = "location from neighbors"
    
    cls = ClassObj.new(layer)
    style = StyleObj.new(cls)
    color = ColorObj.new()
    color.red = 255
    color.green = 10
    color.blue = 10
    style.color = color
    style.size = 15
    style.symbol = 1

    ActiveRecord::Base.establish_connection(
      :adapter  => 'postgresql',
      :database => 'greenwood_dev',
      :username => 'paul',
      :password => 'kgb0186',
      :host     => 'localhost')
    map.
    #map.mysave
    puts map.inspect
    #map.save('testmap.map')
    img = map.draw
    img.save(shapename+'.png')

  
  
