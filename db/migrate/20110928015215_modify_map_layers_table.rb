class ModifyMapLayersTable < ActiveRecord::Migration
  def self.up
    remove_column :map_layers, :opacity
    remove_column :map_layers, :symbol_type
    remove_column :map_layers, :symbol_file
    remove_column :map_layers, :line_color
    remove_column :map_layers, :fill_color
    drop_table :map_obj
    remove_column :theme_maps, :layers
    remove_column :theme_maps, :height
    remove_column :theme_maps, :width
    drop_table :views
  end

  def self.down
  end
end
