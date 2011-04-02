 
 class MapClass < ActiveRecord::Base
     belongs_to :map_layers
     has_a :map_label
 
 end
 
 class MapLayer < ActiveRecord::Base
    has_many :map_classes
 
 end
 
 class MapLabel < ActiveRecord::Base
   belongs_to :map_classes
   
 
 
 script/generate scaffold MapClass
 name:string
 expression:string
 match_value:string
 
       STYLE
        SYMBOL 0
         OUTLINECOLOR 0 0 0
         COLOR 250 5 30
 
 
 
 script/generate scaffold MapLabel
         FONT arial-bold
        TYPE truetype
        SIZE 11
        POSITION CC
        COLOR 0 0 0
        FORCE true
 
 
 
 script/generate scaffold MapLayer
 
 name:string
 
 short_desc:text
 
 projection:string
 class_item:string

 
 status:string
     ON
     
 data_source:
    '/home/paul/mapserver/data/stream.shp'
    "location from neighbors"

 connection_type:string
      POSTGIS
      
 connection:string 
      "host=localhost dbname=greenwood_dev user=paul password=kgb0186 port=5432"
      
 extent:string
       1259300 254000 1269500 262500

 opacity:integer
       100

 symbol_type:string
    POINT / LINE / POLYGON
    
 point_symbol_file:string
 point_size:string
 point_color:string
 
 line_color:string
 line_width:string
 
 polygon_fill_strategy:string
 polygon_fill_color:string 


    EXTENT 1259532.633428 252753.973920 1272953.746014 262713.223921
    CONNECTIONTYPE POSTGIS
    CONNECTION "host=localhost dbname=greenwood_dev user=paul password=kgb0186 port=5432"
    DATA "location from neighbors"

