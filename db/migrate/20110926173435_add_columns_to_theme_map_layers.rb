class AddColumnsToThemeMapLayers < ActiveRecord::Migration
  def self.up
    add_column :theme_map_layers, :is_base_layer, :boolean, :default => false
    add_column :theme_map_layers, :opacity, :integer, :default => nil
    add_column :theme_map_layers, :line_width, :integer, :default => nil
    add_column :theme_map_layers, :is_interactive, :boolean, :default => false
  end

  def self.down
  end
end
