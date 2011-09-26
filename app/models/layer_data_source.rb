require 'mapscript'
include Mapscript

module MapManager
  
  class PostGisConnection < ActiveRecord::Base
    attr_accessible :is_editable?, :editor_id
    
    def get_geometry
    end
    
    def get_data
    end
    
    def get_srid
    end
    
    def put_geometry
      self.save if validate
    end
    
    def validate
    end
  end
  
  class ShapefileConnection
    
    def get_data
    end
  end
  
  
  class LayerDataConnection < ActiveRecord::Base
    
    attr_accessible :connection_type, :is_editable?
  end # class DataSource

end # module MapManager
