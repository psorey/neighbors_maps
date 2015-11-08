class ChangeThemeMapAttrs < ActiveRecord::Migration
  def change
    drop_table :mapped_lines

    create_table :user_lines do |t|
    # t.geometry :geometry, srid: 3875
      t.string   :properties
      t.integer  :map_layer_id
      t.integer  :user_id
   #   t.line_string  :geom, srid: 3875, use_typemod: true
    end

   # add_column :user_lines, :geometry, :geometry, :srid => 3857 
   execute "SELECT AddGeometryColumn ('public','user_lines','geometry',3857,'LINESTRING' ,2, true); "
 #SELECT AddGeometryColumn ('my_schema','my_spatial_table','geom',4326,'POINT',2); 
  end
end
